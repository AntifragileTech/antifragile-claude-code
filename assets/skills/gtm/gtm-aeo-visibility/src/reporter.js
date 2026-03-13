import { writeFileSync } from 'fs';
import { join } from 'path';

export async function generateReport(analysis, profile, runDir) {
  // Generate markdown report
  const markdown = generateMarkdown(analysis, profile);
  writeFileSync(join(runDir, 'report.md'), markdown);
  
  // Generate CSV
  const csv = generateCSV(analysis);
  writeFileSync(join(runDir, 'results.csv'), csv);
}

function generateMarkdown(analysis, profile) {
  const { company, competitors } = profile;
  const { summary, byEngine, byQuery } = analysis;
  
  let md = `# AEO Visibility Report: ${company.name}\n\n`;
  md += `**Generated:** ${new Date().toISOString()}\n\n`;
  
  // Executive Summary
  md += `## Executive Summary\n\n`;
  md += `- **Total Queries:** ${summary.totalQueries}\n`;
  md += `- **Total Mentions:** ${summary.totalMentions}\n`;
  md += `- **Avg Visibility Score:** ${summary.avgVisibilityScore.toFixed(1)}%\n`;
  md += `- **Top Engine:** ${summary.topEngine}\n\n`;
  
  // By Engine
  md += `## Performance by Engine\n\n`;
  for (const [engineName, data] of Object.entries(byEngine)) {
    md += `### ${engineName.toUpperCase()}\n`;
    md += `- Mentions: ${data.mentions}/${data.totalQueries} (${data.visibilityScore.toFixed(1)}%)\n`;
    md += `- Prominent mentions: ${data.prominentMentions}\n`;
    md += `- Avg sentiment: ${data.avgSentiment.toFixed(2)}\n\n`;
  }
  
  // Competitor Comparison
  md += `## Competitor Comparison\n\n`;
  md += `| Competitor | Mentions |\n`;
  md += `|------------|----------|\n`;
  for (const [competitor, count] of Object.entries(summary.competitorComparison)) {
    md += `| ${competitor} | ${count} |\n`;
  }
  md += `\n`;
  
  // Top Performing Queries
  md += `## Top Performing Queries\n\n`;
  const topQueries = Object.entries(byQuery)
    .filter(([_, data]) => data.mentionedIn.length > 0)
    .sort((a, b) => b[1].mentionedIn.length - a[1].mentionedIn.length)
    .slice(0, 20);
  
  for (const [query, data] of topQueries) {
    md += `### "${query}"\n`;
    md += `- Mentioned in: ${data.mentionedIn.join(', ')}\n`;
    if (data.competitorsMentioned.length > 0) {
      md += `- Competitors also mentioned: ${data.competitorsMentioned.join(', ')}\n`;
    }
    md += `\n`;
  }
  
  // Missed Opportunities
  md += `## Missed Opportunities\n\n`;
  const missedQueries = Object.entries(byQuery)
    .filter(([_, data]) => data.mentionedIn.length === 0)
    .slice(0, 20);
  
  for (const [query, data] of missedQueries) {
    const competitorMentions = data.competitorsMentioned.length;
    if (competitorMentions > 0) {
      md += `- **"${query}"** - ${data.competitorsMentioned.join(', ')} mentioned instead\n`;
    } else {
      md += `- "${query}"\n`;
    }
  }
  
  return md;
}

function generateCSV(analysis) {
  const { byQuery } = analysis;
  
  let csv = 'query,chatgpt_mentioned,claude_mentioned,gemini_mentioned,perplexity_mentioned,';
  csv += 'chatgpt_prominence,claude_prominence,gemini_prominence,perplexity_prominence,';
  csv += 'chatgpt_sentiment,claude_sentiment,gemini_sentiment,perplexity_sentiment,';
  csv += 'competitors_mentioned\n';
  
  for (const [query, data] of Object.entries(byQuery)) {
    const row = [
      `"${query.replace(/"/g, '""')}"`,
      data.engines.chatgpt?.mentioned || false,
      data.engines.claude?.mentioned || false,
      data.engines.gemini?.mentioned || false,
      data.engines.perplexity?.mentioned || false,
      data.engines.chatgpt?.prominence || '',
      data.engines.claude?.prominence || '',
      data.engines.gemini?.prominence || '',
      data.engines.perplexity?.prominence || '',
      data.engines.chatgpt?.sentiment ?? '',
      data.engines.claude?.sentiment ?? '',
      data.engines.gemini?.sentiment ?? '',
      data.engines.perplexity?.sentiment ?? '',
      `"${data.competitorsMentioned.join(', ')}"`
    ];
    csv += row.join(',') + '\n';
  }
  
  return csv;
}
