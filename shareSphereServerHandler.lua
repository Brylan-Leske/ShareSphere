--remotes
local remoteFolder = game:GetService("ReplicatedStorage").ShareSphereRemotes
local NewPostEvent = remoteFolder:WaitForChild("NewPostEvent")
local LoadFeedEvent = remoteFolder:WaitForChild("LoadFeedEvent")
local searchCatalogEvent = remoteFolder:WaitForChild("searchCatalogEvent")

--other variables
local HttpService = game:GetService("HttpService")

--handle newPost
local function newPost(player,data)

	local formattedData = data
	formattedData.userId = player.UserId
	formattedData.gamePosted = game.GameId
	formattedData.postTime = os.time()


	local body = HttpService:JSONEncode(formattedData)
	local response = HttpService:RequestAsync({
		Url = "https://us-central1-sparesphere-database-3.cloudfunctions.net/createPost",
		Method = "POST",
		Headers = {
			--["Authorization"] = "bearer " .. identityToken,
			["Content-Type"] = "application/json",
		},
		Body = body,
	})

	local status = response.StatusCode
	if status == 200 then
		return true -- success
	elseif status == 429 then
		return "rate limited"
	else
		warn(response.Body)
		return false -- error
	end
end

NewPostEvent.OnServerInvoke = newPost

local function loadFeed(player,numberOfPosts,startFrom,feedView,feedViewData)
	if not(feedView == "following" or feedView == "allGames" or feedView == "thisGame" or feedView == "profile") then
		warn("Invalid feedView value. "..tostring(feedView))
			return false

	end
	
	local url = "https://us-central1-sparesphere-database-3.cloudfunctions.net/loadFeed?numberOfPosts="..numberOfPosts.."&startAtPost="..startFrom
	
	if feedView == "thisGame" then
		if feedViewData then
			url = url.."&gamePosted="..feedViewData
		end
	elseif feedView == "profile" then
		if feedViewData then
			url = url.."&userPosted="..feedViewData
		end
	end
	
	local response = HttpService:RequestAsync({
		Url = url,
		Method = "GET",
		Headers = {
			["Content-Type"] = "application/json",
		},
	})
	
	local status = response.StatusCode
	if status == 200 then
		return true,response -- success
	else
		warn(response.Body)
		return false -- error
	end
end

LoadFeedEvent.OnServerInvoke = loadFeed

local function searchCatalog(player,keyword)
	warn("send")
	local url = "https://us-central1-sparesphere-database-3.cloudfunctions.net/searchCatalog?category=8&keyword="..keyword

	local response = HttpService:RequestAsync({
		Url = url,
		Method = "GET",
		Headers = {
			["Content-Type"] = "application/json",
		},
	})

	local status = response.StatusCode
	if status == 200 then
		warn("sending to cliend 200")
		return true,response -- success
	else
		warn("something wrong")
		warn(response.Body)
		return false -- error
	end
end

searchCatalogEvent.OnServerInvoke = searchCatalog
