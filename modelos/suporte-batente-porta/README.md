# Suporte para batente magnético na porta

Suporte para prender na porta uma peça redonda (batente/fecho magnético: disco preto largo + corpo com ranhuras + ponta de metal), já que fita dupla-face não segura no acabamento da porta.

Duas versões:

| Versão | Arquivo | Fixação |
|---|---|---|
| **Clipe** (recomendada) | `suporte-batente-porta-clipe.stl` | Encaixe por pressão na borda de baixo da porta, sem furar |
| **Anel** | `suporte-batente-porta-anel.stl` | 3 parafusos de madeira 3,5 mm (ou fita VHB / cola de montagem na face de trás) |
| Teste do clipe | `suporte-batente-porta-clipe-teste.stl` | Fatia de 10 mm só do "U", para testar o aperto antes de imprimir o clipe inteiro |

## Medidas usadas

- Disco preto largo (A): **50 mm** de diâmetro
- Corpo com ranhuras (B): **35 mm** de diâmetro
- Altura total da peça (C): 20 mm
- Espessura do disco preto: **4 mm (estimada, não medida)**
- Porta: **35 mm** de espessura, vão até o chão de **5 mm**

## Como funciona

**Clipe:** um "U" que abraça a borda inferior da porta. A parte de 3 mm passa por baixo da porta (sobram ~2 mm até o chão). No braço do lado da peça há um rebaixo onde o disco preto entra, virado para a porta; o corpo passa por um furo e fica com a ponta de metal para fora. O disco fica preso entre o clipe e a porta. No outro braço, uma nervura faz o aperto.

Montagem: encaixe a peça no rebaixo do clipe e depois empurre o clipe de baixo para cima na borda da porta.

**Anel:** anel de 80 mm com rebaixo para o disco do lado da porta e furo para o corpo na frente. Três furos escareados (cabeça do parafuso fica embutida).

## Dimensões finais

- Clipe: 44 × 61 × 62 mm (espessura × altura na porta × largura ao longo da borda). Centro da peça a ~27 mm acima da borda de baixo da porta.
- Anel: Ø 80 × 6,1 mm.

## Parâmetros principais

Clipe (`suporte-batente-porta-clipe.scad`):

- `door_t` — espessura da porta (35)
- `grip` — quanto a nervura aperta a porta (1,0 mm). Se ficar frouxo, aumente para 1,5; se não entrar, reduza para 0,5.
- `bridge_t` — espessura da parte que passa sob a porta (3 mm; precisa ser menor que o vão)
- `disk_t` — espessura do disco preto (4 mm, **conferir**)
- `width` — largura do clipe ao longo da borda (62 mm)
- `test_fit` — `true` gera só a fatia de teste

Anel (`suporte-batente-porta-anel.scad`): `disk_t`, `plate_d`, `screw_d`, `head_d`, `screw_count`.

Ex.: `openscad -o clipe.stl -D "grip=1.5" -D "disk_t=3.5" suporte-batente-porta-clipe.scad`

## Impressão

**Clipe**

- Orientação: **em pé, com o perfil em "U" deitado na mesa** (como o STL já vem). Assim as camadas seguem o "U" e o braço flexiona sem rachar entre camadas.
- Material: **PETG de preferência** (flexiona sem quebrar e não afrouxa com o tempo); PLA funciona com aperto um pouco menor.
- Altura de camada 0,2 mm, 4 paredes, infill 40% gyroid
- Suporte: não (os furos têm formato de gota com topo plano)
- **Brim: sim**, 5 mm — a área de contato com a mesa é pequena para 62 mm de altura
- Imprima antes a fatia de teste (`-clipe-teste.stl`, ~10 min) e encaixe na porta para conferir o aperto.

**Anel**

- Orientação: frente para baixo (como o STL já vem), rebaixo para cima
- PLA ou PETG, 0,2 mm, 3 paredes, infill 30% gyroid, sem suporte, sem brim

## Histórico

- v1 (2026-11-18): anel com parafusos e clipe por pressão.
