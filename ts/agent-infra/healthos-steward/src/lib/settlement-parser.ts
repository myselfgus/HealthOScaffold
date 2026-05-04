export interface SettlementRecord {
  id: string;
  title: string;
  status: string;
  objective: string;
  territoryIds: string[];
  settlerIds: string[];
  filesInScope: string[];
  invariants: string[];
  restrictions: string[];
  validationCommands: string[];
  doneCriteria: string[];
  residualGaps: string[];
  handoff: string;
  sourceDocs: string[];
}

type ActiveField =
  | "id"
  | "title"
  | "status"
  | "objective"
  | "territory"
  | "settler-profile"
  | "files-in-scope"
  | "invariants"
  | "restrictions"
  | "validation-commands"
  | "done-criteria"
  | "residual-gaps"
  | "handoff"
  | "source-docs"
  | null;

const FIELD_MAP: Record<string, ActiveField> = {
  id: "id",
  title: "title",
  status: "status",
  objective: "objective",
  territory: "territory",
  "settler-profile": "settler-profile",
  "files-in-scope": "files-in-scope",
  invariants: "invariants",
  restrictions: "restrictions",
  "validation-commands": "validation-commands",
  "done-criteria": "done-criteria",
  "residual-gaps": "residual-gaps",
  handoff: "handoff",
};

function extractListItem(line: string): string | null {
  const trimmed = line.trim();
  const checkboxMatch = trimmed.match(/^-\s+\[[ xX]\]\s+(.+)$/);
  if (checkboxMatch) return checkboxMatch[1].trim();
  const numberedMatch = trimmed.match(/^\d+\.\s+(.+)$/);
  if (numberedMatch) return numberedMatch[1].trim();
  const bulletMatch = trimmed.match(/^-\s+(.+)$/);
  if (bulletMatch) {
    const val = bulletMatch[1].trim();
    const backtickMatch = val.match(/^`([^`]+)`/);
    return backtickMatch ? backtickMatch[1] : val;
  }
  return null;
}

export function parseSettlement(markdown: string): SettlementRecord {
  const lines = markdown.split("\n");

  let id = "";
  let title = "";
  let status = "";
  let objective = "";
  let handoff = "";
  const territoryIds: string[] = [];
  const settlerIds: string[] = [];
  const filesInScope: string[] = [];
  const invariants: string[] = [];
  const restrictions: string[] = [];
  const validationCommands: string[] = [];
  const doneCriteria: string[] = [];
  const residualGaps: string[] = [];
  const sourceDocs: string[] = [];

  let currentField: ActiveField = null;
  const textBuffer: string[] = [];

  function flushTextBuffer(): string {
    const result = textBuffer.join("\n").trim();
    textBuffer.length = 0;
    return result;
  }

  function commitCurrentField(): void {
    if (currentField === "objective") {
      objective = flushTextBuffer();
    } else if (currentField === "handoff") {
      handoff = flushTextBuffer();
    } else {
      textBuffer.length = 0;
    }
  }

  for (const line of lines) {
    const trimmed = line.trim();

    // Source docs section header (## Source docs)
    if (/^##\s+Source\s+docs/i.test(trimmed)) {
      commitCurrentField();
      currentField = "source-docs";
      continue;
    }

    // Other h2 section headers reset field tracking
    if (/^##\s+/.test(trimmed)) {
      commitCurrentField();
      currentField = null;
      continue;
    }

    // Bold field definition: **field-name**:
    const fieldMatch = trimmed.match(/^\*\*([^*]+)\*\*:/);
    if (fieldMatch) {
      commitCurrentField();
      const fieldName = fieldMatch[1].toLowerCase().trim();
      currentField = FIELD_MAP[fieldName] ?? null;

      const afterColon = trimmed.slice(fieldMatch[0].length).trim();
      if (afterColon) {
        const backtickVal = afterColon.match(/^`([^`]+)`/);
        if (backtickVal) {
          switch (currentField) {
            case "id": id = backtickVal[1]; currentField = null; break;
            case "title": title = backtickVal[1]; currentField = null; break;
            case "status": status = backtickVal[1]; currentField = null; break;
            default:
              if (currentField === "objective" || currentField === "handoff") {
                textBuffer.push(afterColon);
              }
          }
        } else {
          if (currentField === "objective" || currentField === "handoff") {
            textBuffer.push(afterColon);
          }
        }
      }
      continue;
    }

    if (currentField === null) continue;

    // Separator lines end the current field
    if (trimmed === "---") {
      commitCurrentField();
      currentField = null;
      continue;
    }

    // Text fields collect lines
    if (currentField === "objective" || currentField === "handoff") {
      if (trimmed === "") {
        if (textBuffer.length > 0 && textBuffer[textBuffer.length - 1] !== "") {
          textBuffer.push("");
        }
      } else {
        textBuffer.push(trimmed);
      }
      continue;
    }

    // List fields: skip empty lines and HTML comments
    if (trimmed === "" || trimmed.startsWith("<!--")) continue;

    const item = extractListItem(line);
    if (!item) continue;

    switch (currentField) {
      case "territory": territoryIds.push(item); break;
      case "settler-profile": settlerIds.push(item); break;
      case "files-in-scope": filesInScope.push(item); break;
      case "invariants": invariants.push(item); break;
      case "restrictions": restrictions.push(item); break;
      case "validation-commands": validationCommands.push(item); break;
      case "done-criteria": doneCriteria.push(item); break;
      case "residual-gaps": residualGaps.push(item); break;
      case "source-docs": sourceDocs.push(item); break;
    }
  }

  // Flush any remaining text
  commitCurrentField();

  if (!id) throw new Error("Settlement is missing required field: id");
  if (!title) throw new Error("Settlement is missing required field: title");
  if (!objective) throw new Error("Settlement is missing required field: objective");
  if (territoryIds.length === 0) {
    throw new Error("Settlement is missing required field: territory");
  }

  return {
    id,
    title,
    status,
    objective,
    territoryIds,
    settlerIds,
    filesInScope,
    invariants,
    restrictions,
    validationCommands,
    doneCriteria,
    residualGaps,
    handoff,
    sourceDocs,
  };
}
