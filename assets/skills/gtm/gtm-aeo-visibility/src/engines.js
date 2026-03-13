import { OpenAI } from 'openai';
import Anthropic from '@anthropic-ai/sdk';
import { GoogleGenerativeAI } from '@google/generative-ai';

// Helper: wrap a promise with a timeout
function withTimeout(promise, ms = 30000) {
  return Promise.race([
    promise,
    new Promise((_, reject) => setTimeout(() => reject(new Error(`Request timed out after ${ms}ms`)), ms))
  ]);
}

// Initialize clients
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

const genai = process.env.GOOGLE_API_KEY ? new GoogleGenerativeAI(process.env.GOOGLE_API_KEY) : null;

const perplexity = new OpenAI({
  apiKey: process.env.PERPLEXITY_API_KEY,
  baseURL: 'https://api.perplexity.ai'
});

// Engine implementations
const allEngines = {
  async chatgpt(query) {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [{ role: 'user', content: query }],
      max_tokens: 1000
    });
    return response.choices[0].message.content;
  },

  async claude(query) {
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      messages: [{ role: 'user', content: query }]
    });
    return response.content[0].text;
  },

  async gemini(query) {
    const model = genai.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    const result = await model.generateContent(query);
    return result.response.text();
  },

  async perplexity(query) {
    const response = await perplexity.chat.completions.create({
      model: 'sonar-pro',
      messages: [{ role: 'user', content: query }],
      max_tokens: 1000
    });
    return response.choices[0].message.content;
  }
};

// Only include engines that have API keys configured
const engines = {};
if (process.env.OPENAI_API_KEY) engines.chatgpt = allEngines.chatgpt;
if (process.env.ANTHROPIC_API_KEY) engines.claude = allEngines.claude;
if (process.env.GOOGLE_API_KEY) engines.gemini = allEngines.gemini;
if (process.env.PERPLEXITY_API_KEY) engines.perplexity = allEngines.perplexity;

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

const CONCURRENCY_PER_ENGINE = 10;
const INTER_QUERY_DELAY_MS = 100;

export async function runEngines(queries, options = {}) {
  const engineNames = Object.keys(engines);
  const progressCounts = {};

  // Run a single engine's queries with concurrency control
  async function runSingleEngine(engineName) {
    progressCounts[engineName] = 0;

    const tasks = queries.map((query, i) => async () => {
      // Small staggered delay to avoid burst
      await new Promise(resolve => setTimeout(resolve, i * INTER_QUERY_DELAY_MS));

      let result;
      try {
        const response = await withTimeout(engines[engineName](query), 30000);
        result = { query, response, timestamp: new Date().toISOString(), error: null };
      } catch (error) {
        result = { query, response: null, timestamp: new Date().toISOString(), error: error.message };
      }

      progressCounts[engineName]++;
      if (options.onProgress) {
        options.onProgress(engineName, progressCounts[engineName] - 1, queries.length);
      }

      return result;
    });

    const results = await runWithConcurrency(tasks, CONCURRENCY_PER_ENGINE);

    return { engineName, results };
  }

  // Run ALL engines in parallel
  const engineResults = await Promise.all(
    engineNames.map(name => runSingleEngine(name))
  );

  // Assemble results object
  const results = {};
  for (const { engineName, results: engineData } of engineResults) {
    results[engineName] = engineData;
  }

  return results;
}
