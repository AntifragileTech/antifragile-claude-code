import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Run tasks with bounded concurrency
async function runWithConcurrency(tasks, limit) {
  const results = [];
  const executing = new Set();
  for (const task of tasks) {
    const p = task().then(r => { executing.delete(p); return r; });
    executing.add(p);
    results.push(p);
    if (executing.size >= limit) await Promise.race(executing);
  }
  return Promise.all(results);
}

const ANALYSIS_CONCURRENCY = 20;

export async function analyzeResults(responses, profile) {
  const { company, competitors } = profile;
  const analysis = {
    byEngine: {},
    byQuery: {},
    summary: {
      totalQueries: 0,
      totalMentions: 0,
      avgVisibilityScore: 0,
      topEngine: null,
      competitorComparison: {}
    }
  };

  // Collect all analysis tasks
  const analysisTasks = [];
  for (const [engineName, engineResponses] of Object.entries(responses)) {
    for (const item of engineResponses) {
      if (!item.response) continue;
      analysisTasks.push({ engineName, query: item.query, response: item.response });
    }
  }

  // Run all analysis calls in parallel with concurrency limit
  let completed = 0;
  const tasks = analysisTasks.map(({ engineName, query, response }) => async () => {
    const result = await analyzeSingleResponse(response, company.name, competitors, query);
    completed++;
    if (completed % 20 === 0 || completed === analysisTasks.length) {
      console.log(`  Analysis: ${completed}/${analysisTasks.length}`);
    }
    return { engineName, query, result };
  });

  const analysisResults = await runWithConcurrency(tasks, ANALYSIS_CONCURRENCY);

  // Initialize engine tracking
  for (const [engineName, engineResponses] of Object.entries(responses)) {
    analysis.byEngine[engineName] = {
      totalQueries: engineResponses.length,
      mentions: 0,
      prominentMentions: 0,
      sentimentScores: []
    };
  }

  // Assemble results from parallel analysis
  const allQueries = new Set();
  for (const { engineName, query, result } of analysisResults) {
    allQueries.add(query);

    if (result.mentioned) {
      analysis.byEngine[engineName].mentions++;
      if (result.prominence === 'high') {
        analysis.byEngine[engineName].prominentMentions++;
      }
    }
    analysis.byEngine[engineName].sentimentScores.push(result.sentiment);

    if (!analysis.byQuery[query]) {
      analysis.byQuery[query] = { engines: {}, mentionedIn: [], competitorsMentioned: [] };
    }
    analysis.byQuery[query].engines[engineName] = result;

    if (result.mentioned) {
      analysis.byQuery[query].mentionedIn.push(engineName);
    }

    for (const competitor of result.competitorsMentioned) {
      if (!analysis.byQuery[query].competitorsMentioned.includes(competitor)) {
        analysis.byQuery[query].competitorsMentioned.push(competitor);
      }
    }
  }

  // Calculate engine averages
  for (const [engineName, engineData] of Object.entries(analysis.byEngine)) {
    const scores = engineData.sentimentScores.filter(s => s !== null);
    engineData.avgSentiment =
      scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;
    engineData.visibilityScore =
      (engineData.mentions / engineData.totalQueries) * 100;
  }

  // Calculate summary stats
  analysis.summary.totalQueries = allQueries.size;
  analysis.summary.totalMentions = Object.values(analysis.byEngine)
    .reduce((sum, eng) => sum + eng.mentions, 0);

  const engineScores = Object.entries(analysis.byEngine)
    .map(([name, data]) => ({ name, score: data.visibilityScore }))
    .sort((a, b) => b.score - a.score);

  analysis.summary.avgVisibilityScore =
    engineScores.reduce((sum, e) => sum + e.score, 0) / engineScores.length;
  analysis.summary.topEngine = engineScores[0].name;

  // Competitor comparison
  for (const competitor of competitors) {
    const competitorMentions = Object.values(analysis.byQuery)
      .filter(q => q.competitorsMentioned.includes(competitor))
      .length;
    analysis.summary.competitorComparison[competitor] = competitorMentions;
  }

  return analysis;
}

async function analyzeSingleResponse(response, companyName, competitors, query) {
  const prompt = `Analyze this AI response for mentions and sentiment.

Query: ${query}
Response: ${response}

Company to check: ${companyName}
Competitors to check: ${competitors.join(', ')}

Analyze:
1. Is ${companyName} mentioned? (yes/no) — only if the name "${companyName}" literally appears in the response text.
2. Prominence: If mentioned, is it prominent (high/medium/low)? High = first 2 sentences, Medium = middle, Low = end/footnote
3. Sentiment: How is ${companyName} portrayed? (-1 to 1 scale: -1=negative, 0=neutral, 1=positive)
4. Which competitors from the list are explicitly mentioned BY NAME in the response? Only include a competitor if their name literally appears in the response text. Do NOT include competitors that are merely relevant to the topic but not actually named. Return an empty array if none are mentioned by name.

Return JSON:
{
  "mentioned": boolean,
  "prominence": "high" | "medium" | "low" | null,
  "sentiment": number (-1 to 1) or null,
  "competitorsMentioned": string[]
}`;

  try {
    const result = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' }
    });
    
    return JSON.parse(result.choices[0].message.content);
  } catch (error) {
    return {
      mentioned: false,
      prominence: null,
      sentiment: null,
      competitorsMentioned: []
    };
  }
}
