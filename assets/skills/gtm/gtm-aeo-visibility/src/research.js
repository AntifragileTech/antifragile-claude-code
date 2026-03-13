import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

export async function researchCompany(clientName, websiteUrl) {
  // This would integrate with OpenClaw's web_search
  // For now, placeholder that asks user to provide info
  
  console.log(`\n📋 Please provide information about ${clientName}:`);
  console.log('(In production, this will auto-research via web_search)\n');
  
  // Return structure - in real implementation this would be filled by web_search + LLM
  return {
    name: clientName,
    website: websiteUrl || `https://${clientName}.com`,
    description: 'Company description (auto-generated)',
    products: [],
    keyFeatures: [],
    positioning: '',
    targetAudience: ''
  };
}

export async function discoverCompetitors(companyProfile) {
  // This would use web_search to find competitors
  // Placeholder for now
  
  const prompt = `Based on this company profile, list 5-8 main competitors:
  
Company: ${companyProfile.name}
Description: ${companyProfile.description}

Return a JSON array of competitor names only, e.g. ["Competitor A", "Competitor B"]`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' }
  });
  
  const result = JSON.parse(response.choices[0].message.content);
  return result.competitors || [];
}
