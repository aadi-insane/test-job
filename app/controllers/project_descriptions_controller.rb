class ProjectDescriptionsController < ApplicationController
  def create
    keywords = params[:keywords]

    if keywords.present?
      @description = generate_project_description(keywords)
    else
      @description = "Please enter some keywords to generate a description."
    end

    render "projects/new"
  end

  private

  def generate_project_description(keywords)
    client = OpenRouter::Client.new(access_token: ENV["OPENROUTER_API_KEY"])

    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a helpful assistant that writes project descriptions." },
          { role: "user", content: "Generate a project description using these keywords: #{keywords}" }
        ],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content").strip
  rescue => e
    "Error generating description: #{e.message}"
  end
end
