local_server_ip = "" -- your ip address
local_server_ip = "http://" .. local_server_ip
deposit_url = local_server_ip .. "/deposit_request"
withdraw_url = local_server_ip .. "/get_withdraws"

httpse = game:GetService("HttpService")

function send_mail(user, gems, message)
    game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Send"):InvokeServer(user, message, "Currency", "69824fb964104ed4954a112fe3c12868", gems)
end

function get_mail()
    inbox = game.ReplicatedStorage.Network['Mailbox: Get']:InvokeServer().Inbox
    return inbox
end

while 1 do
    pcall(function()
        print("depo and withdraw cycle")
        wait(3)
        mail = get_mail()
        uuidlist = {}
        for _, gift in pairs(mail) do
            code = gift.Message
            amount = gift.Item.data._am
            request({
                Method = "POST",
                Url = deposit_url,
                Body = httpse:JSONEncode({gems = amount, message = code})
            })
            table.insert(uuidlist, gift.uuid)
        end
        game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Claim"):InvokeServer(uuidlist)

        print("sent deposits to server")

        withdraws = request({
            Method = "GET",
            Url = withdraw_url
        }).Body

        withdraws = httpse:JSONDecode(withdraws)

        for _, withdraw in pairs(withdraws) do
            send_mail(withdraw.user, withdraw.amount-10000, "Withdraw")
        end

        print("sent withdraws")
    end)
end
