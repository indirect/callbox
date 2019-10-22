require "bundler/setup"
require "sinatra"
require "twilio-ruby"

use Rack::TwilioWebhookAuthentication, ENV.fetch("TWILIO_AUTH_TOKEN")

post "/call" do
  puts "Incoming call"
  content_type "text/xml"

  Twilio::TwiML::VoiceResponse.new do |r|
    r.gather(numDigits: 4, action: "/code") do |g|
      g.say(message: "Enter code", voice: "alice")
    end

    # If teher isn"t any input, loop
    r.redirect("/call")
  end
end

post "/code" do
  puts "Got code #{params["Digits"]}"
  content_type "text/xml"

  if params["Digits"] == ENV["CODE"]
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
