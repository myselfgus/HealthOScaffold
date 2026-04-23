export interface UserAgentSession {
  userId: string;
  cpfHash: string;
  mode: "self-service";
}

export class UserAgentRuntime {
  async start(session: UserAgentSession): Promise<void> {
    console.log("[runtime-user-agent] start", session.userId);
  }
}
