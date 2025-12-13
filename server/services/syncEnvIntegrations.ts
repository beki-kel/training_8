/**
 * Auto-sync integration tokens from .env to database
 * This ensures integrations work properly even when using .env tokens
 * instead of OAuth or Replit connectors
 */

import { storage } from "../storage";
import { integrationTokens } from "./integrationTokens";

export async function syncEnvIntegrationsForTeam(teamId: string): Promise<void> {
  console.log(`[EnvSync] Syncing .env integrations for team ${teamId}...`);
  
  const synced: string[] = [];
  
  // Sync Notion
  if (process.env.NOTION_TOKEN) {
    try {
      const existing = await storage.getIntegrationByType(teamId, "notion");
      
      if (!existing) {
        await storage.createIntegration({
          teamId,
          type: "notion",
          status: "connected",
          accessToken: process.env.NOTION_TOKEN,
          refreshToken: null,
          tokenExpiresAt: null,
          metadata: { source: "env_file" },
        });
        synced.push("Notion");
        console.log(`[EnvSync] ✓ Added Notion integration from .env`);
      } else if (existing.status !== "connected" && process.env.NOTION_TOKEN) {
        // Update if exists but not connected
        await storage.updateIntegration(existing.id, {
          status: "connected",
          accessToken: process.env.NOTION_TOKEN,
        });
        synced.push("Notion (updated)");
        console.log(`[EnvSync] ✓ Updated Notion integration from .env`);
      }
    } catch (error) {
      console.error(`[EnvSync] Failed to sync Notion:`, error);
    }
  }
  
  // Sync Slack
  if (process.env.SLACK_BOT_TOKEN && process.env.SLACK_APP_TOKEN) {
    try {
      const existing = await storage.getIntegrationByType(teamId, "slack");
      
      if (!existing) {
        await storage.createIntegration({
          teamId,
          type: "slack",
          status: "connected",
          accessToken: process.env.SLACK_BOT_TOKEN,
          refreshToken: null,
          tokenExpiresAt: null,
          metadata: {
            source: "env_file",
            app_token: process.env.SLACK_APP_TOKEN,
            signing_secret: process.env.SLACK_SIGNING_SECRET,
          },
        });
        synced.push("Slack");
        console.log(`[EnvSync] ✓ Added Slack integration from .env`);
      } else if (existing.status !== "connected") {
        await storage.updateIntegration(existing.id, {
          status: "connected",
          accessToken: process.env.SLACK_BOT_TOKEN,
          metadata: {
            ...existing.metadata as object,
            app_token: process.env.SLACK_APP_TOKEN,
            signing_secret: process.env.SLACK_SIGNING_SECRET,
          },
        });
        synced.push("Slack (updated)");
        console.log(`[EnvSync] ✓ Updated Slack integration from .env`);
      }
    } catch (error) {
      console.error(`[EnvSync] Failed to sync Slack:`, error);
    }
  }
  
  // Sync Google Drive
  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET && process.env.GOOGLE_DRIVE_REFRESH_TOKEN) {
    try {
      const existing = await storage.getIntegrationByType(teamId, "google_drive");
      
      if (!existing) {
        await storage.createIntegration({
          teamId,
          type: "google_drive",
          status: "connected",
          accessToken: process.env.GOOGLE_DRIVE_ACCESS_TOKEN || "",
          refreshToken: process.env.GOOGLE_DRIVE_REFRESH_TOKEN,
          tokenExpiresAt: null,
          metadata: { source: "env_file" },
        });
        synced.push("Google Drive");
        console.log(`[EnvSync] ✓ Added Google Drive integration from .env`);
      }
    } catch (error) {
      console.error(`[EnvSync] Failed to sync Google Drive:`, error);
    }
  }
  
  // Sync Zoom
  if (process.env.ZOOM_ACCOUNT_ID && process.env.ZOOM_CLIENT_ID && process.env.ZOOM_CLIENT_SECRET) {
    try {
      const existing = await storage.getIntegrationByType(teamId, "zoom");
      
      if (!existing && process.env.ZOOM_ACCESS_TOKEN) {
        await storage.createIntegration({
          teamId,
          type: "zoom",
          status: "connected",
          accessToken: process.env.ZOOM_ACCESS_TOKEN,
          refreshToken: process.env.ZOOM_REFRESH_TOKEN || null,
          tokenExpiresAt: null,
          metadata: { 
            source: "env_file",
            account_id: process.env.ZOOM_ACCOUNT_ID 
          },
        });
        synced.push("Zoom");
        console.log(`[EnvSync] ✓ Added Zoom integration from .env`);
      }
    } catch (error) {
      console.error(`[EnvSync] Failed to sync Zoom:`, error);
    }
  }
  
  if (synced.length > 0) {
    console.log(`[EnvSync] Synced ${synced.length} integration(s): ${synced.join(", ")}`);
  } else {
    console.log(`[EnvSync] No new integrations to sync from .env`);
  }
}

/**
 * Sync integrations for all teams on startup
 * This ensures .env tokens are available in the database for all teams
 */
export async function syncEnvIntegrationsForAllTeams(): Promise<void> {
  try {
    const teams = await storage.getAllTeams();
    
    if (teams.length === 0) {
      console.log(`[EnvSync] No teams found, skipping sync`);
      return;
    }
    
    console.log(`[EnvSync] Syncing .env integrations for ${teams.length} team(s)...`);
    
    for (const team of teams) {
      await syncEnvIntegrationsForTeam(team.id);
    }
    
    console.log(`[EnvSync] ✅ All teams synced successfully!`);
  } catch (error) {
    console.error(`[EnvSync] Error syncing integrations:`, error);
  }
}

