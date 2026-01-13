import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
  region: process.env.AWS_REGION || "ap-south-1",
});

export const dynamoDb = DynamoDBDocumentClient.from(client);

export const TABLE_NAMES = {
  USERS: process.env.DYNAMODB_USERS_TABLE || "bbms-users",
  DONORS: process.env.DYNAMODB_DONORS_TABLE || "bbms-donors", 
  REQUESTS: process.env.DYNAMODB_REQUESTS_TABLE || "bbms-requests",
  INVENTORY: process.env.DYNAMODB_INVENTORY_TABLE || "bbms-inventory"
};
