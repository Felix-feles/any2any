import React, { useEffect, useMemo, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { Download, Upload, Repeat, RotateCw, Code2, Eye, EyeOff, Copy, Check, Settings2, Rocket, TerminalSquare, Layers } from "lucide-react";
import Editor from "@monaco-editor/react";

/**
 * HaxePivot Code Converter – single-file demo app
 * ------------------------------------------------
 * Goals
 * - Responsive desktop/mobile UI
 * - "Chunk → Pivot AST → Generate" pipeline
 * - Pivot inspired by Deno AST (ESTree-ish) and extended with a few Haxe-like nodes
 * - Rule-based mini parsers for JS and Python (demo); plug-in point for LLM conversion
 * - No hard frontend limit on input size (streamed chunk conversion)
 *
 * NOTE: This is a demo-quality implementation to bootstrap a real project.
 * For production, replace the naive parsers with robust ones (tree-sitter, SWC, etc.)
 * or an LLM toolchain. See the `convertChunkWithLLM` stub below.
 */

// ----------------------
// Pivot AST definitions
// ----------------------

type PivotKind =
  | "Module"
  | "Block"
  | "FunctionDecl"
  | "VarDecl"
  | "Assignment"
  | "CallExpr"
  | "IfStmt"
  | "ReturnStmt"
  | "Literal"
  | "Identifier"
  | "BinaryExpr"
  | "ForStmt"
  | "WhileStmt"
  | "ClassDecl"
  | "MethodDecl";

export type PivotNode = {
  kind: PivotKind;
  // generic fields; concrete nodes define a subset
  name?: string;
  value?: any;
  left?: PivotNode;
  right?: PivotNode;
  test?: PivotNode;
  body?: PivotNode | PivotNode[];
  params?: PivotNode[];
  callee?: PivotNode;
  arguments?: PivotNode[];
  declarations?: { id: PivotNode; init?: PivotNode }[];
  operator?: string;
  superClass?: PivotNode | null;
  methods?: PivotNode[];
  // location (optional)
  loc?: { start: number; end: number };
};

export type PivotModule = PivotNode & { kind: "Module"; body: PivotNode[] };

// ----------------------
// Language options
// ----------------------

const LANGUAGES = [
  { id: "auto", label: "Auto" },
  { id: "javascript", label: "JavaScript" },
  { id: "python", label: "Python" },
  { id: "haxe", label: "Haxe" },
  { id: "csharp", label: "C#" },
  { id: "java", label: "Java" },
  { id: "cpp", label: "C++" },
  { id: "ts", label: "TypeScript" },
  { id: "go", label: "Go" },
  { id: "php", label: "PHP" },
  { id: "ruby", label: "Ruby" },
  { id: "lua", label: "Lua" },
];

const TARGETS = [
  { id: "javascript", label: "JavaScript" },
  { id: "python", label: "Python" },
  { id: "haxe", label: "Haxe" },
  { id: "csharp", label: "C#" },
  { id: "java", label: "Java" },
  { id: "cpp", label: "C++" },
];

// ----------------------
// Utilities
// ----------------------

function downloadText(filename: string, content: string) {
  const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

function copyToClipboard(text: string) {
  return navigator.clipboard.writeText(text);
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// ----------------------
// Auto language detection (very naive, demo only)
// ----------------------

function detectLang(code: string): string {
  const trimmed = code.trim();
  if (/^\s*#\!\/usr\/bin\/env\s+node|\bfunction\b|=>|console\./.test(code)) return "javascript";
  if (/^\s*#\!.*python|\bdef\b|\bprint\(|:\n/.test(code)) return "python";
  if (/\bclass\s+\w+\s*\{/.test(code) && /:\s*\w+\s*;/.test(code)) return "haxe";
  return "javascript"; // default guess
}

// ----------------------
// Chunker (streams big inputs)
// ----------------------

type Chunk = { id: number; text: string; start: number; end: number };

function chunkSource(code: string, approxChunkSize = 4000): Chunk[] {
  if (code.length <= approxChunkSize) return [{ id: 0, text: code, start: 0, end: code.length }];
  const lines = code.split(/\n/);
  const chunks: Chunk[] = [];
  let buf: string[] = [];
  let size = 0;
  let start = 0;
  let id = 0;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    buf.push(line);
    size += line.length + 1;
    if (size >= approxChunkSize || /^(function|class|def|#\s*region)/.test(line)) {
      const text = buf.join("\n");
      chunks.push({ id: id++, text, start, end: start + text.length });
      start += text.length + 1;
      buf = [];
      size = 0;
    }
  }
  if (buf.length) {
    const text = buf.join("\n");
    chunks.push({ id: id++, text, start, end: start + text.length });
  }
  return chunks;
}

// ----------------------
// Naive JS parser → Pivot (demo)
// ----------------------

function jsToPivot(code: string): PivotModule {
  const body: PivotNode[] = [];
  // Functions
  const funcRe = /function\s+(\w+)\s*\(([^)]*)\)\s*\{([\s\S]*?)\}/g;
  let m: RegExpExecArray | null;
  while ((m = funcRe.exec(code))) {
    const [, name, paramsRaw, bodyRaw] = m;
    const params = paramsRaw
      .split(",")
      .map((p) => p.trim())
      .filter(Boolean)
      .map((p) => ({ kind: "Identifier", name: p } as PivotNode));
    body.push({
      kind: "FunctionDecl",
      name,
      params,
      body: [{ kind: "Block", body: [{ kind: "ReturnStmt", value: { kind: "Literal", value: null } }] }],
    });
  }
  // Var decls
  const varRe = /(var|let|const)\s+(\w+)\s*=\s*([^;]+);/g;
  while ((m = varRe.exec(code))) {
    const [, , name, init] = m;
    body.push({
      kind: "VarDecl",
      declarations: [
        {
          id: { kind: "Identifier", name },
          init: { kind: "Literal", value: init.trim() },
        },
      ],
    });
  }
  return { kind: "Module", body };
}

// ----------------------
// Naive Python parser → Pivot (demo)
// ----------------------

function pyToPivot(code: string): PivotModule {
  const body: PivotNode[] = [];
  const lines = code.split(/\n/);
  const funcRe = /^\s*def\s+(\w+)\(([^)]*)\)\s*:/;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const m = line.match(funcRe);
    if (m) {
      const [, name, paramsRaw] = m;
      const params = paramsRaw
        .split(",")
        .map((p) => p.trim())
        .filter(Boolean)
        .map((p) => ({ kind: "Identifier", name: p } as PivotNode));
      body.push({ kind: "FunctionDecl", name, params, body: [{ kind: "Block", body: [] }] });
    }
    const assign = line.match(/^\s*(\w+)\s*=\s*(.+)$/);
    if (assign) {
      const [, name, init] = assign;
      body.push({
        kind: "VarDecl",
        declarations: [
          { id: { kind: "Identifier", name }, init: { kind: "Literal", value: init.trim() } },
        ],
      });
    }
  }
  return { kind: "Module", body };
}

// ----------------------
// Pivot → Generators
// ----------------------

function pivotToJS(mod: PivotModule): string {
  const out: string[] = [];
  for (const node of mod.body) {
    switch (node.kind) {
      case "FunctionDecl": {
        const params = (node.params || []).map((p) => p.name).join(", ");
        out.push(`function ${node.name}(${params}) {\n  // TODO: body\n}`);
        break;
      }
      case "VarDecl": {
        const decls = (node.declarations || [])
          .map((d) => `let ${d.id.name}${d.init ? " = " + toLiteralString(d.init) : ""};`)
          .join("\n");
        out.push(decls);
        break;
      }
      default:
        out.push(`// Unsupported node: ${node.kind}`);
    }
  }
  return out.join("\n\n");
}

function pivotToPython(mod: PivotModule): string {
  const out: string[] = [];
  for (const node of mod.body) {
    switch (node.kind) {
      case "FunctionDecl": {
        const params = (node.params || []).map((p) => p.name).join(", ");
        out.push(`def ${node.name}(${params}):\n    pass`);
        break;
      }
      case "VarDecl": {
        const decls = (node.declarations || [])
          .map((d) => `${d.id.name} = ${toLiteralString(d.init || { kind: "Literal", value: "None" })}`)
          .join("\n");
        out.push(decls);
        break;
      }
      default:
        out.push(`# Unsupported node: ${node.kind}`);
    }
  }
  return out.join("\n\n");
}

function pivotToHaxe(mod: PivotModule): string {
  const out: string[] = ["package;", "class Main {", "  public static function main() {\n    // TODO\n  }", "}"];
  for (const node of mod.body) {
    switch (node.kind) {
      case "FunctionDecl": {
        const params = (node.params || []).map((p) => `${p.name}:Dynamic`).join(", ");
        out.push(`\nfunction ${node.name}(${params}):Dynamic {\n  // TODO\n}`);
        break;
      }
      case "VarDecl": {
        const decls = (node.declarations || [])
          .map((d) => `var ${d.id.name}${d.init ? " = " + toLiteralString(d.init) : ""};`)
          .join("\n");
        out.push(decls);
        break;
      }
      default:
        out.push(`// Unsupported node: ${node.kind}`);
    }
  }
  return out.join("\n");
}

function toLiteralString(n?: PivotNode): string {
  if (!n) return "null";
  if (n.kind === "Literal") return String(n.value);
  if (n.kind === "Identifier") return n.name || "";
  return "null";
}

// ----------------------
// LLM stub (plug your provider)
// ----------------------

async function convertChunkWithLLM(chunk: string, sourceLang: string): Promise<PivotModule> {
  // This stub illustrates where you'd call an LLM endpoint
  // (OpenAI-compatible or local). It returns a very small pivot as a demo.
  // Replace with your actual API call.
  await sleep(30); // simulate latency
  const guessed = sourceLang === "auto" ? detectLang(chunk) : sourceLang;
  if (guessed === "python") return pyToPivot(chunk);
  return jsToPivot(chunk);
}

// ----------------------
// Conversion Orchestrator
// ----------------------

type ConversionProgress = {
  total: number;
  done: number;
  status: string;
};

async function convertBigSource(
  code: string,
  sourceLang: string,
  targetLang: string,
  useLLM: boolean,
  onProgress?: (pg: ConversionProgress) => void
): Promise<{ pivot: PivotModule; output: string }>
{
  const chunks = chunkSource(code);
  const merged: PivotModule = { kind: "Module", body: [] };

  for (let i = 0; i < chunks.length; i++) {
    const { text } = chunks[i];
    onProgress?.({ total: chunks.length, done: i, status: `Analyse du chunk ${i + 1}/${chunks.length}` });

    let pivotPart: PivotModule;
    if (useLLM) pivotPart = await convertChunkWithLLM(text, sourceLang);
    else {
      const lang = sourceLang === "auto" ? detectLang(text) : sourceLang;
      pivotPart = lang === "python" ? pyToPivot(text) : jsToPivot(text);
    }

    merged.body.push(...pivotPart.body);
    onProgress?.({ total: chunks.length, done: i + 1, status: `Converti ${i + 1}/${chunks.length}` });
    // Small yield to keep UI responsive
    await sleep(0);
  }

  // Generate
  let output = "";
  switch (targetLang) {
    case "javascript":
      output = pivotToJS(merged);
      break;
    case "python":
      output = pivotToPython(merged);
      break;
    case "haxe":
      output = pivotToHaxe(merged);
      break;
    default:
      output = pivotToJS(merged);
  }

  return { pivot: merged, output };
}

// ----------------------
// Demo samples
// ----------------------

const SAMPLES: Record<string, string> = {
  javascript: `// JS sample\nconst x = 42;\nfunction add(a, b) { return a + b; }`,
  python: `# Py sample\nx = 42\n\ndef add(a, b):\n    return a + b`,
  haxe: `class Demo {\n  static function main() {\n    var x = 42;\n  }\n}`,
};

// ----------------------
// UI – App Component
// ----------------------

export default function App() {
  const [input, setInput] = useState<string>(SAMPLES.javascript);
  const [output, setOutput] = useState<string>("");
  const [sourceLang, setSourceLang] = useState<string>("auto");
  const [targetLang, setTargetLang] = useState<string>("python");
  const [useLLM, setUseLLM] = useState<boolean>(false);
  const [showPivot, setShowPivot] = useState<boolean>(false);
  const [pivotJSON, setPivotJSON] = useState<string>("{")
  const [working, setWorking] = useState<boolean>(false);
  const [prog, setProg] = useState<ConversionProgress>({ total: 0, done: 0, status: "" });
  const [copied, setCopied] = useState<boolean>(false);

  useEffect(() => {
    if (copied) {
      const t = setTimeout(() => setCopied(false), 1500);
      return () => clearTimeout(t);
    }
  }, [copied]);

  const startConvert = async () => {
    setWorking(true);
    setOutput("");
    try {
      const { pivot, output } = await convertBigSource(
        input,
        sourceLang,
        targetLang,
        useLLM,
        (pg) => setProg(pg)
      );
      setOutput(output);
      setPivotJSON(JSON.stringify(pivot, null, 2));
    } catch (e: any) {
      setOutput(`// Erreur: ${e?.message || e}`);
    } finally {
      setWorking(false);
    }
  };

  const loadSample = (lang: string) => {
    setInput(SAMPLES[lang] || "");
    setSourceLang(lang === "javascript" || lang === "python" ? lang : "auto");
  };

  const progressPct = prog.total ? Math.round((prog.done / prog.total) * 100) : 0;

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-slate-50 text-slate-900 p-4 md:p-8">
      <div className="max-w-7xl mx-auto grid gap-6">
        <header className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl md:text-4xl font-semibold tracking-tight flex items-center gap-2">
              <Layers className="w-8 h-8" /> HaxePivot Converter
            </h1>
            <p className="text-sm text-slate-600 mt-1">
              Convertisseur multi-langages via un AST pivot (inspiré Deno AST + touches Haxe). Démo UI responsive.
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" onClick={() => loadSample("javascript")}>JS sample</Button>
            <Button variant="outline" onClick={() => loadSample("python")}>Py sample</Button>
            <Button variant="default" onClick={startConvert} disabled={working}>
              <Repeat className="w-4 h-4 mr-2" /> Convertir
            </Button>
          </div>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2"><Upload className="w-4 h-4"/> Entrée</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div className="col-span-1">
                  <Label>Langage source</Label>
                  <Select value={sourceLang} onValueChange={setSourceLang}>
                    <SelectTrigger className="mt-1"><SelectValue placeholder="Auto"/></SelectTrigger>
                    <SelectContent>
                      {LANGUAGES.map(l => (
                        <SelectItem key={l.id} value={l.id}>{l.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="col-span-1">
                  <Label>Langage cible</Label>
                  <Select value={targetLang} onValueChange={setTargetLang}>
                    <SelectTrigger className="mt-1"><SelectValue placeholder="Choisir"/></SelectTrigger>
                    <SelectContent>
                      {TARGETS.map(t => (
                        <SelectItem key={t.id} value={t.id}>{t.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="col-span-1 flex items-end justify-between gap-2">
                  <div className="flex items-center gap-2">
                    <Switch id="llm" checked={useLLM} onCheckedChange={setUseLLM} />
                    <Label htmlFor="llm">Utiliser LLM (stub)</Label>
                  </div>
                  <Button variant="outline" size="icon" title="Réinitialiser" onClick={() => setInput("")}> <RotateCw className="w-4 h-4"/> </Button>
                </div>
              </div>

              <div className="border rounded-xl overflow-hidden">
                <Editor
                  height="40vh"
                  defaultLanguage="javascript"
                  language={sourceLang === "auto" ? detectLang(input) : sourceLang}
                  value={input}
                  onChange={(v) => setInput(v || "")}
                  options={{ fontSize: 14, minimap: { enabled: false } }}
                />
              </div>

              {working && (
                <div className="space-y-2">
                  <Progress value={progressPct} />
                  <div className="text-xs text-slate-500">{prog.status}</div>
                </div>
              )}

              <div className="flex flex-wrap gap-2">
                <label className="inline-flex items-center gap-2 cursor-pointer">
                  <Input type="file" className="hidden" onChange={(e) => {
                    const file = e.target.files?.[0];
                    if (!file) return;
                    const reader = new FileReader();
                    reader.onload = () => setInput(String(reader.result || ""));
                    reader.readAsText(file);
                  }}/>
                  <span className="px-3 py-2 border rounded-lg text-sm flex items-center gap-2"><Upload className="w-4 h-4"/> Importer un fichier</span>
                </label>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2"><Download className="w-4 h-4"/> Sortie</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="border rounded-xl overflow-hidden">
                <Editor
                  height="40vh"
                  defaultLanguage="python"
                  language={targetLang}
                  value={output}
                  onChange={(v) => setOutput(v || "")}
                  options={{ fontSize: 14, minimap: { enabled: false } }}
                />
              </div>

              <div className="flex flex-wrap gap-2">
                <Button variant="outline" onClick={() => { downloadText(`converted.${targetLang}.txt`, output); }}>
                  <Download className="w-4 h-4 mr-2"/> Télécharger
                </Button>
                <Button variant="secondary" onClick={async () => { await copyToClipboard(output); setCopied(true); }}>
                  {copied ? <Check className="w-4 h-4 mr-2"/> : <Copy className="w-4 h-4 mr-2"/>}
                  {copied ? "Copié !" : "Copier"}
                </Button>
                <Button onClick={startConvert} disabled={working}>
                  <Rocket className="w-4 h-4 mr-2"/> Relancer
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        <Card className="shadow-sm">
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Settings2 className="w-4 h-4"/> Inspecteur & Pipeline</CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="pivot" className="w-full">
              <TabsList>
                <TabsTrigger value="pivot"><Code2 className="w-4 h-4 mr-1"/> AST Pivot</TabsTrigger>
                <TabsTrigger value="log"><TerminalSquare className="w-4 h-4 mr-1"/> Journal</TabsTrigger>
                <TabsTrigger value="about"><Eye className="w-4 h-4 mr-1"/> À propos</TabsTrigger>
              </TabsList>
              <TabsContent value="pivot">
                <div className="grid gap-2">
                  <div className="flex items-center gap-2">
                    <Switch id="showPivot" checked={showPivot} onCheckedChange={setShowPivot} />
                    <Label htmlFor="showPivot">Afficher le JSON du module pivot</Label>
                  </div>
                  {showPivot && (
                    <Textarea className="font-mono text-xs" rows={16} value={pivotJSON} onChange={(e) => setPivotJSON(e.target.value)} />
                  )}
                </div>
              </TabsContent>
              <TabsContent value="log">
                <div className="text-sm text-slate-600">
                  <p>
                    Pipeline : <strong>Chunker</strong> → <strong>Parser/LLM</strong> → <strong>Fusion</strong> → <strong>Générateur</strong>.
                    Cette démo implémente des parseurs minimaux JS/Python et des générateurs JS/Python/Haxe.
                  </p>
                  <ul className="list-disc ml-6 mt-2">
                    <li>Remplacez les parseurs par tree-sitter/SWC/ANTLR selon vos besoins.</li>
                    <li>Connectez votre LLM dans <code>convertChunkWithLLM</code> (OpenAI-compatible, local, etc.).</li>
                    <li>Pas de limite stricte en front : les entrées très volumineuses sont traitées par morceaux.</li>
                  </ul>
                </div>
              </TabsContent>
              <TabsContent value="about">
                <div className="prose prose-sm max-w-none">
                  <h3>HaxePivot Converter</h3>
                  <p>
                    AST pivot inspiré de Deno AST/ESTree, enrichi de quelques nœuds Haxe (types dynamiques simples). Démo UI mobile/desktop avec Tailwind + shadcn/ui + Monaco.
                  </p>
                  <h4>Limitations (démo)</h4>
                  <ul>
                    <li>Les parseurs inclus sont rudimentaires (extraction de fonctions/variables).</li>
                    <li>Le générateur Haxe produit un squelette minimal.</li>
                    <li>Pour une conversion « 100/100 », il faut des parseurs/typage complets + règles de mapping sémantique.</li>
                  </ul>
                  <h4>Emballage Desktop & Mobile</h4>
                  <ul>
                    <li><strong>Desktop</strong> : packager avec <code>Tauri</code> (frontend React → binaire léger).</li>
                    <li><strong>Mobile</strong> : partager les vues/logic via <code>Expo/React Native</code> ou publier une PWA installable.</li>
                  </ul>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>

        <footer className="text-xs text-slate-500 text-center py-4">
          © {new Date().getFullYear()} HaxePivot Converter – Démo. Aucune garantie. 
        </footer>
      </div>
    </div>
  );
}
