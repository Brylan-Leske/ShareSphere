# HTTP Endpoint Documentation: `createPost`

This documentation provides information about the HTTP endpoint function `createPost`, which is part of a Firebase Functions project. The `createPost` function allows you to create a new post by sending a POST request to the endpoint.

## Endpoint Details

- **Endpoint URL:** `https://your-project-url/createPost`
- **HTTP Method:** `POST`
- **Content Type:** `application/json`

## Request Body

The `createPost` endpoint expects a JSON object in the request body with the following fields:

- `postTime` (required): A timestamp representing the post time. Must be a number.
- `wasPromoted` (required): Indicates whether the post was promoted. Must be a boolean.
- `containsImage` (required): Indicates whether the post contains an image. Must be a boolean.
- `postIsAComment` (required): Indicates whether the post is a comment. Must be a boolean.
- `containsDonation` (required): Indicates whether the post contains a donation. Must be a boolean.
- `containsText` (required): Indicates whether the post contains text. Must be a boolean.
- `userId` (required): The ID of the user creating the post. Must be a number.
- `gamePosted` (required): The ID of the game associated with the post. Must be a number.

### Conditional Fields

Certain fields are required conditionally based on the values of other fields:

- If `containsImage` is `true`, the `imageId` field is required and must be a number.
- If `containsText` is `true`, the `text` field is required and must be a string.
- If `containsDonation` is `true`, the `donationButtons` field is required and must be an array.
- If `postIsAComment` is `true`, the `parentPost` field is required and must be a number.

## Response

The endpoint responds with an HTTP status code and a response body.

- If the request is successful, the response will have an HTTP status code of `200` and the response body will contain a success message along with the ID of the created post.
- If the request is invalid or missing required fields, the response will have an HTTP status code of `400` and the response body will contain an error message.

### Successful Response

Example response body:

```json
"Post added with ID: 123456789"
```

### Error Response

Example error response body:

```json
"Missing required fields"
```

## Implementation Details

The `createPost` function performs the following steps:

1. Retrieves the request body from the POST request.
2. Checks if all the required fields (`postTime`, `wasPromoted`, `containsImage`, `postIsAComment`, `containsDonation`, `containsText`, `userId`, `gamePosted`) are present and have the expected types. If any required field is missing or has an invalid type, it sends a `400` error response.
3. Checks the conditional required fields based on the values of other fields. If any conditional required field is missing or has an invalid type, it sends a `400` error response.
4. Initializes the Firebase Admin SDK.
5. Retrieves a reference to the `Posts` collection in the Firebase Realtime Database.
6. Pushes the post data to the `Posts` collection, generating a unique key for the new post.
7. Sets the `postId` field of the newly created post to the generated key.
8. Retrieves a reference to the `Posts` node under the `Users` collection for the user who created the post.
9. Pushes the `postId` to the `Posts

` node for the user.
10. Sends a successful response with a message indicating that the post was added along with the ID of the created post.

## Usage

To create a new post, send an HTTP POST request to the specified URL (`https://your-project-url/createPost`) with a valid JSON payload containing the required and optional fields.

Example request:

```http
POST https://your-project-url/createPost
Content-Type: application/json

{
  "postTime": 1652879400,
  "wasPromoted": false,
  "containsImage": true,
  "imageId": 123,
  "postIsAComment": false,
  "containsDonation": false,
  "containsText": true,
  "text": "This is my post",
  "userId": 456,
  "gamePosted": 789
}
```

This request creates a new post with the specified data.

Make sure to handle the response and error messages appropriately in your client application.
