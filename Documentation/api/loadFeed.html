# HTTP Endpoint Documentation: `loadFeed`

This documentation provides information about the HTTP endpoint function `loadFeed`, which is part of a Firebase Functions project. The `loadFeed` function retrieves a feed of posts based on specified parameters and returns the posts to the client.

## Endpoint Details

- **Endpoint URL:** `https://your-project-url/loadFeed`
- **HTTP Method:** `GET`
- **Content Type:** `application/json`

## Parameters

The `loadFeed` endpoint accepts the following query parameters:

1. `numberOfPosts` (required): The number of posts to retrieve. Must be a positive number greater than 0.
2. `startAtPost` (required): The index of the post to start retrieving from. Must be a non-negative number.
3. `gamePosted` (optional): Filter the posts by a specific game. Must be an integer.
4. `userPosted` (optional): Filter the posts by a specific user. Must be an integer.

## Response

The endpoint responds with an HTTP status code and a JSON response body.

- If the request is successful, the response will have an HTTP status code of `200` and the response body will contain an array of posts.
- If the request is invalid or missing required parameters, the response will have an HTTP status code of `400` and the response body will contain an error message.

### Successful Response

Example response body:

```json
[
  {
    "postId": "123",
    "title": "Example Post",
    "content": "This is an example post.",
    "timePosted": 1645628400000,
    "userId": 456,
    "gamePosted": 789
  },
  {
    "postId": "456",
    "title": "Another Post",
    "content": "This is another post.",
    "timePosted": 1645632000000,
    "userId": 123,
    "gamePosted": 789
  }
]
```

### Error Response

Example error response body:

```json
{
  "error": "Missing required parameters: numberOfPosts and startAtPost"
}
```

## Implementation Details

The `loadFeed` function performs the following steps:

1. Parses the query parameters from the request URL: `numberOfPosts`, `startAtPost`, `gamePosted`, and `userPosted`.
2. Checks if the required parameters (`numberOfPosts` and `startAtPost`) are present. If not, it sends a `400` error response.
3. Validates that `numberOfPosts` is a positive number greater than 0. If not, it sends a `400` error response.
4. Validates that `startAtPost` is a non-negative number. If not, it sends a `400` error response.
5. Checks if both `gamePosted` and `userPosted` parameters are provided. If so, it sends a `400` error response, as filtering by both is not allowed.
6. Checks if the `gamePosted` parameter is present and is a number. If valid, sets the `searchWithinGame` flag to `true`. If not, sends a `400` error response.
7. Checks if the `userPosted` parameter is present and is a number. If valid, sets the `searchWithinUser` flag to `true`. If not, sends a `400` error response.
8. Initializes the Firebase Admin SDK.
9. Retrieves a reference to the `Posts` collection in the Firebase Realtime Database.
10. Declares an empty `postsArray` to store the retrieved posts.
11. If `searchWithinGame` is `true`, retrieves posts filtered by the `gamePosted` parameter from the database, sorts them

 by `timePosted`, and stores them in the `postsArray`.
12. If `searchWithinUser` is `true`, retrieves posts filtered by the `userPosted` parameter from the database, sorts them by `timePosted`, and stores them in the `postsArray`.
13. If neither `searchWithinGame` nor `searchWithinUser` is `true`, retrieves all posts from the database, sorts them by `timePosted`, and stores them in the `postsArray`.
14. Selects the relevant subset of posts based on the `startAtPost` and `numberOfPosts` parameters.
15. Sends a successful response with the `postsArray` as the response body.

## Usage

To use the `loadFeed` endpoint, send an HTTP GET request to the specified URL (`https://your-project-url/loadFeed`) with the appropriate query parameters.

Example request:

```
GET https://your-project-url/loadFeed?numberOfPosts=10&startAtPost=1&gamePosted=123
```

This request retrieves 10 posts starting from the first post (`startAtPost=1`) and filtered by the game with ID `123` (`gamePosted=123`).

## Error Handling

The `loadFeed` function includes error handling for various scenarios:

- Missing required parameters: If `numberOfPosts` or `startAtPost` is missing, the function responds with a `400` status code and an error message indicating the missing parameters.
- Invalid parameters: If `numberOfPosts` or `startAtPost` is not a valid number, the function responds with a `400` status code and an error message indicating the expected format.
- Filtering conflict: If both `gamePosted` and `userPosted` parameters are provided, the function responds with a `400` status code and an error message indicating that filtering by both is not allowed.

Make sure to handle the error responses appropriately in your client application.
