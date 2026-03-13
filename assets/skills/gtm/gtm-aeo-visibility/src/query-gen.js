import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

export async function generateQueries(profile, count = 100) {
  const { company, competitors } = profile;
  
  const prompt = `Generate ${count} diverse search queries that potential customers might ask an AI answer engine (ChatGPT, Perplexity, Claude, etc.) when looking for solutions in ${company.name}'s domain.

Company: ${company.name}
Description: ${company.description}
Competitors: ${competitors.join(', ')}

IMPORTANT: Do NOT include "${company.name}" by name in any query. These must be generic, category-level searches that a potential customer would type BEFORE they know about ${company.name}. The goal is to test whether ${company.name} appears organically in answer engine results for category queries.

Good examples: "best voice AI platform for developers", "how to build an AI phone agent"
Bad examples: "how to use ${company.name} for healthcare", "${company.name} vs Retell AI"

For comparison queries, compare competitors to each other or use generic category terms — never include ${company.name} as one of the compared options.

Generate queries across these categories:
- Problem-based: "How do I solve X?" (generic problem, no brand names)
- Tool discovery: "What's the best tool for Y?"
- Comparisons: "CompetitorA vs CompetitorB" (never ${company.name})
- Use cases: "How to do ABC with [category tool]"
- Recommendations: "Best tools for DEF"
- Integration: "How to integrate [category] with Y"

Mix of:
- Broad category queries (50%)
- Specific feature queries (30%)
- Comparison queries (20%)

Return a JSON array of ${count} query strings.`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' }
  });
  
  const result = JSON.parse(response.choices[0].message.content);
  return result.queries || [];
}
