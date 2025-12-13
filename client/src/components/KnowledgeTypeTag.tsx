import { Badge } from "@/components/ui/badge";

export type KnowledgeType =
  | "policy"
  | "sop"
  | "decision"
  | "fact"
  | "process"
  | "engineering"
  | "product"
  | "technical";

interface KnowledgeTypeTagProps {
  type: KnowledgeType;
}

const typeConfig: Record<
  KnowledgeType,
  { label: string; className: string }
> = {
  policy: { label: "Policy", className: "bg-chart-1/10 text-chart-1 border-chart-1/20" },
  sop: { label: "SOP", className: "bg-chart-2/10 text-chart-2 border-chart-2/20" },
  decision: { label: "Decision", className: "bg-chart-3/10 text-chart-3 border-chart-3/20" },
  fact: { label: "Fact", className: "bg-chart-4/10 text-chart-4 border-chart-4/20" },
  process: { label: "Process", className: "bg-chart-5/10 text-chart-5 border-chart-5/20" },
  engineering: { label: "Engineering Spec", className: "bg-primary/10 text-primary border-primary/20" },
  product: { label: "Product Update", className: "bg-destructive/10 text-destructive border-destructive/20" },
  technical: { label: "Technical", className: "bg-blue-500/10 text-blue-500 border-blue-500/20" },
};

const defaultConfig = { 
  label: "Unknown", 
  className: "bg-gray-500/10 text-gray-500 border-gray-500/20" 
};

export function KnowledgeTypeTag({ type }: KnowledgeTypeTagProps) {
  const config = typeConfig[type] || defaultConfig;
  
  return (
    <Badge
      variant="outline"
      className={`${config.className} text-xs font-medium uppercase tracking-wide border`}
      data-testid={`tag-knowledge-type-${type}`}
    >
      {config.label}
    </Badge>
  );
}
