#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.SmsApi do
  def send_rain_warning do
    # dev_key
    # sid SK685b861af958ea79b26078761fd8bd87
    # secret 0vGRNdeEuoCEyEOWmX6VOtqheBdntKRJ
    #     curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACda0862c704d6cfd37314d1ef661bf078/Messages.json \
    # --data-urlencode "Body=Hi there$EXCLAMATION_MARK" \
    # --data-urlencode "From=+15017122661" \
    # --data-urlencode "To=+15558675310" \
    # -u ACda0862c704d6cfd37314d1ef661bf078:your_auth_token

    HTTPoison.post(
      "https://api.twilio.com/2010-04-01/Accounts/ACda0862c704d6cfd37314d1ef661bf078/Messages.json",
      {:form, [Body: "Test", To: "+13039996435", From: "+17632923353"]},
      %{},
      hackney: [
        basic_auth:
          {"ACda0862c704d6cfd37314d1ef661bf078",
           "efca807e8829d451591f2b73dd22919f"}
      ]
    )
  end
end
