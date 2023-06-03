--variables

--remotes
local remoteFolder = game:GetService("ReplicatedStorage").ShareSphereRemotes
local NewPostEvent = remoteFolder:WaitForChild("NewPostEvent")
local LoadFeedEvent = remoteFolder:WaitForChild("LoadFeedEvent")
local searchCatalogEvent = remoteFolder:WaitForChild("searchCatalogEvent")

--other variables

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService('TweenService')
local UserService = game:GetService("UserService")

--gui parts
local ShareSphereGUI = script:WaitForChild("ShareSphereGUI")
ShareSphereGUI.Parent =  player:WaitForChild("PlayerGui")
local Configuration = ShareSphereGUI.Configuration

local mainFrame = ShareSphereGUI.mainFrame
local bottomBar = mainFrame.bottombar
local middleFrame = mainFrame.middleFrame
local topbar = mainFrame.topbar

local topbar_border = topbar.border
local topbar_contentFrame = topbar.contentFrame
local topbar_logo = topbar_contentFrame.logo

local bottombar_border = bottomBar.border
local bottombar_contentFrame = bottomBar.contentFrame

local homeButton = bottombar_contentFrame.homeButton
local notificationsButton = bottombar_contentFrame.notificationsButton
local profileButton = bottombar_contentFrame.profileButton

local pageButtons = middleFrame.pageButtons
local pageButtonsBorder = pageButtons.border

local feedPageSelector = pageButtons.feedPageSelector
local thisGameButton = feedPageSelector.thisGameButton
local followingButton = feedPageSelector.followingButton
local allGamesButton = feedPageSelector.allGamesButton

local templates = ShareSphereGUI.templates
local postTemplate = templates.postTemplate

local createPostPageControls = pageButtons.createPostPageControls

local createPostButton = middleFrame.createPostButton

local loadingFrame = mainFrame.loadingFrame

local feed = middleFrame.feedPage
local profile= middleFrame.profilePage
local notifications = middleFrame.notificationsPage
local createPost = middleFrame.createPostPage

local currentPage = feed --the current user page
local homePageFeed = "thisGame"

local currentlyLoading = false

local pagePath = {}

local loadedPosts = 0
local allPostsLoaded = false
local lastLoadedPostsAt = 700000000000

--functions

--loading screen handler
local loadingImage = loadingFrame.loadingDetailsFrame.loadingImage
local loadingImageTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
local loadingImageTweenGoals = {Rotation = 360}
local loadingImageTween = tweenService:Create(loadingImage, loadingImageTweenInfo, loadingImageTweenGoals)
local function loading(state)--Handle loading screen
	if state == true then
		loadingFrame.Visible = true
		currentlyLoading = true
		loadingImageTween:Play()

	elseif state == false then
		loadingFrame.Visible = false
		currentlyLoading = false
		loadingImageTween:Cancel()
	else
		warn("An error has occured: Invalid arguments passed to loading function")
		currentlyLoading = false
	end
end

--alert handler
local alertFrame = mainFrame.alertFrame
local alertButton = alertFrame.alertDetailsFrame.alertButtons.closeButton
local alertMessage = alertFrame.alertDetailsFrame.alertMessage.alertText
local function alert(close,alertText)--handles alerts
	if close == false then
		if alertText then
			alertMessage.Text = alertText
			alertFrame.Visible = true
		else
			warn("Something went wrong... Error:012")
		end
	else if close == true then
			alertFrame.Visible = false
		end
	end
	
end

local function convertTimestamp(timestamp)--converts unix time to a readable format for posts
	local currentTime = os.time()
	local elapsedTime = currentTime - timestamp

	-- Calculate elapsed time in seconds, minutes, hours, days, months, and years
	local seconds = elapsedTime % 60
	local minutes = math.floor(elapsedTime / 60) % 60
	local hours = math.floor(elapsedTime / 3600) % 24
	local days = math.floor(elapsedTime / 86400) % 30
	local months = math.floor(elapsedTime / 2592000) % 12
	local years = math.floor(elapsedTime / 31536000)

	-- Format the result based on the largest unit of time
	if years > 0 then
		return years .. " years"
	elseif months > 0 then
		return months .. " months"
	elseif days > 0 then
		return days .. " days"
	elseif hours > 0 then
		return hours .. " hours"
	elseif minutes > 0 then
		return minutes .. " mins"
	else
		return seconds .. " secs"
	end
end

local function clearFeed()--clears entire feed except for the UIListLayout
	local loadedPostsArray = feed:GetChildren()

	if #loadedPostsArray > 0 then

		for i = 1,#loadedPostsArray,1 do
			if loadedPostsArray[i].Name ~= "UIListLayout" then
				loadedPostsArray[i]:Remove()
			end
		end
	end
	loadedPosts = 0
	allPostsLoaded = false
end

local function populateFeed(data)

	if data then
		local posts = game:GetService("HttpService"):JSONDecode(data["Body"])

		--checks if all posts have been loaded, if so it adds a "you've reached the end" text to the feed
		if #posts <1 then
			allPostsLoaded = true
			local endLabel = templates:WaitForChild("endLabel"):Clone()
			endLabel.Parent = feed
			endLabel.Visible = true
			endLabel.LayoutOrder = 1000001
		end

		-- Access individual posts
		for i, post in ipairs(posts) do
			if post == nil then
				-- Handle case when post is null
				allPostsLoaded = true
			elseif post == "" then
				allPostsLoaded = true
			elseif not post then
				allPostsLoaded = true
			else--handles real posts
				local postFrame = postTemplate:Clone()
				postFrame.Name = post.postId

				if post.containsText == true then
					postFrame.content.postText.Visible = true
					postFrame.content.postText.Text = post.text
				elseif post.containsText == false then
					postFrame.content.postText:Remove()
				end

				if post.containsImage == true then
					postFrame.content.postImage.Visible = true
					postFrame.content.postImage.Image = post.imageId
				elseif post.containsImage == false then
					postFrame.content.postImage:Remove()
				end

				postFrame.user.viewProfileButton.time.Text = "• "..tostring(convertTimestamp(post.postTime))

				local PLACEHOLDER_IMAGE = "http://www.roblox.com/asset/?id=6034287594" -- replace with placeholder image

				-- fetch the thumbnail
				local userId = post.userId
				local content, isReady = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

				-- set the ImageLabel's content to the user thumbnail
				if isReady and content then
					postFrame.user.viewProfileButton.userProfile.Image = content
				else
					createPost.postFrame.user.userProfile.Image = PLACEHOLDER_IMAGE
					warn("Something went wrong... Error:004")
				end

				local success, result = pcall(function()
					return UserService:GetUserInfosByUserIdsAsync({ userId })
				end)

				if success then
					for _, userInfo in ipairs(result) do
						postFrame.user.viewProfileButton.username.Text = "@" .. userInfo.Username
						postFrame.user.viewProfileButton.nickname.Text = userInfo.DisplayName
					end
				else
					-- An error occurred
					warn("Something went wrong... Error:005")
				end

				postFrame.LayoutOrder = 1000000 - post.postTime / 10000

				postFrame.Parent = feed
				postFrame.Visible = true

				postFrame.user.viewProfileButton.time.Size = UDim2.new(0, postFrame.user.viewProfileButton.time.TextBounds.X + 5, 0.5, 0)
				postFrame.user.viewProfileButton.username.Size = UDim2.new(0, postFrame.user.viewProfileButton.username.TextBounds.X + 5, 0.5, 0)
				postFrame.user.viewProfileButton.nickname.Size = UDim2.new(0, postFrame.user.viewProfileButton.nickname.TextBounds.X + 5, 0.5, 0)

				loadedPosts = loadedPosts + 1
			end
		end

		return true
	else
		warn("Something went wrong... Error:002")
		return false
	end
end

local function post(postData)
	local containsText = false
	local postText = postData
	if postText then
		containsText = true
	else 
		containsText = false
	end

	local data = {
		["containsDonation"]= false,
		["containsImage"]= false,
		["containsText"]= containsText,
		["imageId"]= 0,
		["parentPost"]= 0,
		["postIsAComment"]= false,
		["text"]= postText,
		["wasPromoted"]= false
	}

	local status = NewPostEvent:InvokeServer(data)
	return status
end

local function changePage(back,page,data)--handles changing pages
	if back == false then
		if page == feed then
			currentPage = feed
			profile.Visible = false
			notifications.Visible = false
			feed.Visible = true
			createPost.Visible = false

			feedPageSelector.Visible = true--show selector for feed page
			createPostPageControls.Visible = false
			createPostButton.Visible = true



			--get recent posts
			local status = false
			loading(true)
			if data then
				clearFeed()
				local numberOfPosts = 5
				local startFrom = loadedPosts + 1
				local feedView
				local feedViewData

				if data == "thisGame" then
					feedView = "thisGame"
					feedViewData = game.GameId
				elseif data == "allGames" then
					feedView = "allGames"
					feedViewData = nil
				elseif data == "following" then
					feedView = "following"
					feedViewData = nil
				end

				local responseStatus,response = LoadFeedEvent:InvokeServer(numberOfPosts,startFrom,feedView,feedViewData)
				lastLoadedPostsAt = tonumber(os.time())
				local status = populateFeed(response)
				repeat task.wait() until status == true
				loading(false)
			end
		elseif page == notifications then
			currentPage = notifications
			profile.Visible = false
			notifications.Visible = true
			feed.Visible = false
			createPost.Visible = false
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = false
			createPostButton.Visible = false
		elseif page == profile then
			currentPage = profile
			profile.Visible = true
			notifications.Visible = false
			feed.Visible = false
			createPost.Visible = false
			createPostButton.Visible = false
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = false
		elseif page == createPost then
			currentPage = createPost
			profile.Visible = false
			notifications.Visible = false
			feed.Visible = false
			createPost.Visible = true
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = true
			createPostButton.Visible = false
		end


	elseif back == true then
		local toGo = pagePath[#pagePath-1]
		if toGo == feed then
			data = homePageFeed
			currentPage = feed
			profile.Visible = false
			notifications.Visible = false
			feed.Visible = true
			createPost.Visible = false
			feedPageSelector.Visible = true--show selector for feed page
			createPostPageControls.Visible = false
			createPostButton.Visible = true
		elseif toGo == notifications then
			currentPage = notifications
			profile.Visible = false
			notifications.Visible = true
			feed.Visible = false
			createPost.Visible = false
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = false
			createPostButton.Visible = false
		elseif toGo == profile then
			currentPage = profile
			profile.Visible = true
			notifications.Visible = false
			feed.Visible = false
			createPost.Visible = false
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = false
			createPostButton.Visible = false
		elseif toGo == createPost then
			currentPage = createPost
			profile.Visible = false
			notifications.Visible = false
			feed.Visible = false
			createPost.Visible = true
			local loadedFromTemplate = templates.createPostPageFrame:Clone()
			loadedFromTemplate.Parent = createPost
			loadedFromTemplate.Visible = true
			feedPageSelector.Visible = false--hide selector for feed page
			createPostPageControls.Visible = true
			createPostButton.Visible = false
		end
		table.remove(pagePath,#pagePath)
	end
end


--handle gui

--handles changing pages via clicking bottom buttons
homeButton.MouseButton1Click:Connect(function()
	changePage(false,feed,homePageFeed)
end)

notificationsButton.MouseButton1Click:Connect(function()
	changePage(false,notifications,true)
end)

profileButton.MouseButton1Click:Connect(function()
	changePage(false,profile,true)
end)

createPostButton.MouseButton1Click:Connect(function()
	changePage(false,createPost)
end)

--change feed view
thisGameButton.MouseButton1Click:Connect(function()
	if homePageFeed ~= "thisGame" then
		homePageFeed = "thisGame"
		thisGameButton.Text = "<u>This Game</u>"
		followingButton.Text = "Following"
		allGamesButton.Text = "All Games"

		changePage(false,feed,"thisGame")
	end
end)

allGamesButton.MouseButton1Click:Connect(function()
	if homePageFeed ~= "allGames" then
		homePageFeed = "allGames"
		thisGameButton.Text = "This Game"
		followingButton.Text = "Following"
		allGamesButton.Text = "<u>All Games</u>"

		changePage(false,feed,"allGames")
	end
end)

followingButton.MouseButton1Click:Connect(function()
	if homePageFeed ~= "following" then
		homePageFeed = "following"
		thisGameButton.Text = "This Game"
		followingButton.Text = "<u>Following</u>"
		allGamesButton.Text = "All Games"

		changePage(false,feed,"following")
	end
end)


--handle posting

createPostPageControls.postButton.MouseButton1Click:Connect(function()
	local postStatus = post(createPost.createPostPageFrame.content.postText.Text)
	loading(true)
	repeat task.wait() until postStatus ~= false
	if postStatus == true then
		
	elseif postStatus == "rate limited" then
		alert(false,"You may only post once per minute. Please try again later.")
	else 
		warn("Something went wrong... Error:011")
	end
	loading(false)

	changePage(false,feed,homePageFeed)
end)


--handle cancel button on createPostPage
createPostPageControls.cancelButton.MouseButton1Click:Connect(function()
	changePage(true)
end)

--add content 
local addContentDropdownButton = createPost.createPostPageFrame.content.postImage.addContentButton
local addContentDropdown = createPost.createPostPageFrame.content.postImage.addContentButton.dropdownMenu

local function openCloseAddContentDropdown()
	if addContentDropdown.Visible == false then
		addContentDropdown.Visible = true
	else
		addContentDropdown.Visible = false
	end
end

addContentDropdownButton.MouseButton1Click:Connect(openCloseAddContentDropdown)

--handle add content dropdown buttons

local addImageButton = addContentDropdown.buttonContainer.image
local addInviteButton = addContentDropdown.buttonContainer.invite
local addDonationButton = addContentDropdown.buttonContainer.donation
local addPollButton = addContentDropdown.buttonContainer.poll
local cancelDropdownButton = addContentDropdown.buttonContainer.cancel

local imageAdder = createPost.imageSelectorContainer
local imageAdderCancelButton = imageAdder.searchBar.cancelButton
local imageAdderSearchBox = imageAdder.searchBar.searchQuery
local imageAdderSearchButton = imageAdder.searchBar.searchButton

local function imageAdderHandler(keyword)
	local imageSelectorImages = imageAdder.imageSelector:GetChildren()

	for i=1,#imageSelectorImages,1 do
		if imageSelectorImages[i].Name ~= "imageTemplate" and imageSelectorImages[i].Name ~= "UIGridLayout" then
			imageSelectorImages[i]:Remove()
		end
	end

	local imageTemplate = imageAdder.imageSelector.imageTemplate

	if keyword then
		loading(true)
		local converted = tonumber(keyword)

		if converted then--check if an id was input
			local clone = imageTemplate:Clone()
			clone.Visible = true
			clone.Image = "http://www.roblox.com/asset/?id="..converted
			clone.Name = tostring(converted)
			clone.Parent = imageAdder.imageSelector			
			-- Wait for the image to load
			local startTime = workspace.DistributedGameTime
			while not clone.IsLoaded do
				local deltaTime = workspace.DistributedGameTime - startTime
				if deltaTime > 1 and deltaTime < 2 then
					clone.Image = "http://www.roblox.com/asset/?id="..converted-1
				elseif deltaTime > 2 then
					clone.Image = "http://www.roblox.com/asset/?id=13618601080"
					break
				end
				task.wait()
			end
			loading(false)
		else--if not an id, then search
			
			
			local success, result = searchCatalogEvent:InvokeServer(keyword)
			
			if success then
				warn(1)
				local images = game:GetService("HttpService"):JSONDecode(result["Body"])
				warn(images)
				for i, image in ipairs(images) do
					warn(2)
					local clone = imageTemplate:Clone()
					clone.Visible = true
					clone.Image = "http://www.roblox.com/asset/?id="..image.AssetId
					clone.Name = tostring(image.AssetId)
					clone.Parent = imageAdder.imageSelector			
					-- Wait for the image to load
					local startTime = workspace.DistributedGameTime
					while not clone.IsLoaded do
						local deltaTime = workspace.DistributedGameTime - startTime
						if deltaTime > 1 and deltaTime < 2 then
							warn(3)
							clone.Image = "http://www.roblox.com/asset/?id="..image.AssetId-1
						elseif deltaTime > 2 then
							warn(4)
							clone.Image = "http://www.roblox.com/asset/?id=13618601080"
							clone:Remove()
							break
						end
						task.wait()
					end
				end
				loading(false)
			else
				warn("Something went wrong... Error:009")
				
			end
		end
	else 
		imageAdder.searchBar.searchQuery.Text = ""	
	end
end

local function handleContentDropdownButtons(button)
	if button == addImageButton then
		imageAdderHandler(false)
		imageAdder.Visible = true
		openCloseAddContentDropdown()
	elseif button == cancelDropdownButton then
		openCloseAddContentDropdown()
		imageAdder.Visible = false
		imageAdderHandler(false)
	end
end

addImageButton.MouseButton1Click:Connect(function()
	handleContentDropdownButtons(addImageButton)
end)
cancelDropdownButton.MouseButton1Click:Connect(function()
	handleContentDropdownButtons(cancelDropdownButton)
end)

imageAdderCancelButton.MouseButton1Click:Connect(function()
	imageAdderHandler(false)
	imageAdder.Visible = false
end)

imageAdderSearchButton.MouseButton1Click:Connect(function()
	imageAdderHandler(imageAdderSearchBox.Text)
end)

--handle scrolling on feed

feed:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if feed.CanvasPosition.Y + feed.AbsoluteSize.Y >= feed.AbsoluteCanvasSize.Y-100 and currentlyLoading == false and allPostsLoaded == false then
		if math.abs(lastLoadedPostsAt - tonumber(os.time()))>2 then -- the > determines how often new posts can be loaded

			local numberOfPosts = 5
			local startFrom = loadedPosts + 1
			local feedView
			local feedViewData

			if homePageFeed == "thisGame" then
				feedView = "thisGame"
				feedViewData = game.GameId
			elseif homePageFeed == "allGames" then
				feedView = "allGames"
				feedViewData = nil
			elseif homePageFeed == "following" then
				feedView = "following"
				feedViewData = nil
			end
			loading(true)
			local responseStatus,response = LoadFeedEvent:InvokeServer(numberOfPosts,startFrom,feedView,feedViewData)
			local status = populateFeed(response)
			repeat task.wait() until status == true
			loading(false)
			lastLoadedPostsAt = tonumber(os.time())
		end
	end
end)


--handle closing alert
alertButton.MouseButton1Click:Connect(function()
	alert(true)
end)

--handle start


local function applyLocalDetails()--apply local user details
	local PLACEHOLDER_IMAGE = "http://www.roblox.com/asset/?id=6034287594" -- replace with placeholder image

	-- fetch the thumbnail
	local userId = player.UserId
	local content, isReady = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	--get the user data
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({userId})
	end)

	-- set the ImageLabel's content to the user thumbnail
	local allGUIElements = ShareSphereGUI:GetDescendants()

	local localUserThumbnails = {}
	local localUserUsernames = {}
	local localUserNicknames = {}

	--get all local user images/etc

	for i = 1, #allGUIElements, 1 do
		local class
		if allGUIElements[i]:GetAttribute("Class") then class = allGUIElements[i]:GetAttribute("Class")
		elseif allGUIElements[i]:GetAttribute("class") then class = allGUIElements[i]:GetAttribute("class")
			--else
			--	warn("This gui element does not have a class assigned: ".. tostring(allGUIElements[i]))
			--	warn(allGUIElements[i])
		end

		if class == "localUserProfilePic" then
			table.insert(localUserThumbnails,allGUIElements[i])
		elseif class == "localUserNickname" then
			table.insert(localUserNicknames,allGUIElements[i])
		elseif class == "localUserUsername" then
			table.insert(localUserUsernames,allGUIElements[i])
		end

	end

	--apply all local profile pictures
	for i=1, #localUserThumbnails, 1 do
		localUserThumbnails[i].Image = (isReady and content) or PLACEHOLDER_IMAGE
	end

	--apply all local user data
	if success then
		for i=1, #localUserNicknames, 1 do
			localUserNicknames[i].Text = result[1].displayName
		end

		for i=1, #localUserUsernames, 1 do
			localUserUsernames[i].Text = "@"..result[1].name
		end
	else
		-- An error occurred
		warn("Something went wrong... Error:008")
	end	
end

applyLocalDetails()
changePage(false,feed,"thisGame")
