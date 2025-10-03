# main.py - ChitChat Backend using FastAPI

import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import Dict, List

# --- In-memory storage for demonstration. Replace with a proper database. ---
# This ConnectionManager will handle all active WebSocket connections.
class ConnectionManager:
    def __init__(self):
        # Store active connections: {group_id: [websockets]}
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, group_id: str):
        await websocket.accept()
        if group_id not in self.active_connections:
            self.active_connections[group_id] = []
        self.active_connections[group_id].append(websocket)
        print(f"New connection in group {group_id}. Total: {len(self.active_connections[group_id])}")

    def disconnect(self, websocket: WebSocket, group_id: str):
        if group_id in self.active_connections:
            self.active_connections[group_id].remove(websocket)
            print(f"Connection closed in group {group_id}. Remaining: {len(self.active_connections[group_id])}")

    async def broadcast(self, message: str, group_id: str):
        if group_id in self.active_connections:
            for connection in self.active_connections[group_id]:
                await connection.send_text(message)

manager = ConnectionManager()

# --- FastAPI App Initialization ---
app = FastAPI(
    title="ChitChat API",
    description="Backend for the ChitChat real-time messaging application.",
    version="0.1.0"
)

# --- WebSocket Endpoint for Real-time Chat ---
@app.websocket("/ws/chat/{group_id}")
async def websocket_chat_endpoint(websocket: WebSocket, group_id: str):
    await manager.connect(websocket, group_id)
    try:
        while True:
            # The server waits to receive a message from a client
            data = await websocket.receive_text()
            # Once a message is received, it broadcasts it to all clients in the same group
            print(f"Message received in group {group_id}: {data}")
            await manager.broadcast(f"Message: {data}", group_id)
    except WebSocketDisconnect:
        manager.disconnect(websocket, group_id)
        await manager.broadcast(f"A user has left the chat", group_id)

# --- REST API Endpoints ---
# These are placeholders. You would implement full CRUD logic with database interaction.

@app.get("/")
def read_root():
    return {"message": "Welcome to the ChitChat API"}

# Example of a future endpoint for the Group Roles feature
@app.post("/groups/{group_id}/members/assign-role")
async def assign_group_role(group_id: str, role_assignment: dict):
    # --- Authentication and Permission Check (CRITICAL!) ---
    # 1. Verify the requesting user is authenticated.
    # 2. Check if the user is an admin of this specific group_id.
    # 3. If not, return a 403 Forbidden error.
    
    # --- Role Assignment Logic ---
    # 4. Extract user_id and new_role from the role_assignment dictionary.
    # 5. Update the user's role in the 'group_members' database table.
    
    # --- Notify Group Members ---
    # 6. Broadcast a system message to the group about the role change.
    user_id = role_assignment.get("user_id")
    new_role = role_assignment.get("role")
    
    print(f"Admin request to assign role '{new_role}' to user '{user_id}' in group '{group_id}'")
    
    # In a real app, you would save this to your database.
    # For now, we just broadcast the change.
    await manager.broadcast(
        f"System: User {user_id} has been assigned the role of {new_role}.",
        group_id
    )
    
    return {"status": "success", "message": f"Role '{new_role}' assigned to user '{user_id}'."}

# Add more endpoints for authentication, user profiles, payments, etc.

# To run this app:
# 1. Install FastAPI and Uvicorn: pip install fastapi "uvicorn[standard]"
# 2. Run the server: uvicorn main:app --reload
