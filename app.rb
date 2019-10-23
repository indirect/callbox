require "sinatra"
require "twilio-ruby"
require "json"

CODE = ENV.fetch("CODE")

use Rack::TwilioWebhookAuthentication, ENV.fetch("TWILIO_AUTH_TOKEN")

post "/call" do
  puts "Incoming call"
  puts "Params: #{params.inspect}"
  puts JSON.pretty_generate(request.env)
  content_type "text/xml"

  Twilio::TwiML::VoiceResponse.new do |r|
    r.gather(numDigits: CODE.size, action: "/code") do |g|
      g.say(message: "Enter code", voice: "alice")
    end

    # If there isn't any input, loop
    r.redirect("/call")
  end
end

post "/code" do
  puts "Got code #{params["Digits"]}"
  content_type "text/xml"

  if params["Digits"] == CODE
    Twilio::TwiML::VoiceResponse.new do |r|
      r.play(digits: "3w3w3")
    end
  else
    Twilio::TwiML::VoiceResponse.new do |r|
      r.say(message: "Invalid code", voice: "alice")
      r.pause
      r.redirect("/call")
    end
  end
end
