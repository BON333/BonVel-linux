# Graph Report - bono  (2026-11-04)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1521 nodes · 1562 edges · 35 communities (11 shown, 24 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `48c23f81`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 7
- Community 8
- Community 9
- Community 10
- Community 13
- Community 14
- Community 15
- Community 19
- Community 20
- Community 22
- Community 23
- Community 24
- Community 25
- Community 31
- Community 32
- Community 33

## God Nodes (most connected - your core abstractions)
1. `colors` - 450 edges
2. `colors` - 450 edges
3. `colors` - 450 edges
4. `bright` - 9 edges
5. `normal` - 9 edges
6. `bonvel-instalar.sh script` - 7 edges
7. `montar_alvo()` - 4 edges
8. `ler()` - 3 edges
9. `screendump()` - 3 edges
10. `ler()` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (35 total, 24 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.00
Nodes (450): colors, activityBar.activeBackground, activityBar.background, activityBar.dropBackground, activityBar.foreground, activityBar.inactiveForeground, activityBarBadge.background, activityBarBadge.foreground (+442 more)

### Community 1 - "Community 1"
Cohesion: 0.00
Nodes (450): colors, activityBar.activeBackground, activityBar.background, activityBar.dropBackground, activityBar.foreground, activityBar.inactiveForeground, activityBarBadge.background, activityBarBadge.foreground (+442 more)

### Community 2 - "Community 2"
Cohesion: 0.00
Nodes (450): colors, activityBar.activeBackground, activityBar.background, activityBar.dropBackground, activityBar.foreground, activityBar.inactiveForeground, activityBarBadge.background, activityBarBadge.foreground (+442 more)

### Community 3 - "Community 3"
Cohesion: 0.10
Nodes (9): captura(), cmd(), enviar_teclas(), gif(), ler(), screendump(), cmd(), enviar_teclas() (+1 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (25): accent, background, black, blue, cyan, green, magenta, red (+17 more)

### Community 7 - "Community 7"
Cohesion: 0.44
Nodes (7): erro(), montado(), montar_alvo(), passo(), bonvel-instalar.sh script, sim(), tem_rede()

### Community 8 - "Community 8"
Cohesion: 0.40
Nodes (4): name, $schema, tokenColors, type

### Community 9 - "Community 9"
Cohesion: 0.40
Nodes (4): name, $schema, tokenColors, type

### Community 10 - "Community 10"
Cohesion: 0.40
Nodes (4): name, $schema, tokenColors, type

### Community 13 - "Community 13"
Cohesion: 0.83
Nodes (3): automated_script(), script_cmdline(), .automated_script.sh script

### Community 14 - "Community 14"
Cohesion: 0.83
Nodes (3): arrancar(), captura(), test-arranque.sh script

## Knowledge Gaps
- **24 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `colors` connect `Community 0` to `Community 8`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.0044444444444444444 - nodes in this community are weakly interconnected._
- **Why does `colors` connect `Community 1` to `Community 9`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.0044444444444444444 - nodes in this community are weakly interconnected._
- **Why does `colors` connect `Community 2` to `Community 10`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.0044444444444444444 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.0960591133004926 - nodes in this community are weakly interconnected._