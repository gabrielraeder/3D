# CLAUDE.md — Modelos 3D para impressão

Esta pasta (`C:\writechoice\3D`) guarda os arquivos de impressão 3D do Gabriel. Quando ele pedir um modelo ("faz um suporte para…", "cria uma caixa com tampa…"), você cria o modelo como **código paramétrico**, gera o STL e deixa tudo pronto para abrir no Bambu Studio.

## Idioma

- Conversa, README e textos para o usuário: **português do Brasil**.
- Código, nomes de variáveis, nomes de parâmetros e comentários no código: **inglês**.
- Termos técnicos ficam em inglês (infill, brim, overhang, slicer etc.).

## Impressora

**Bambu Lab A1 Combo** (com AMS lite):

- Volume útil: **256 × 256 × 256 mm**
- Bico: 0,4 mm
- AMS lite: até 4 filamentos/cores na mesma impressão

Regras:

- Projete para caber em 256 × 256 × 256 mm, de preferência com alguns milímetros de margem (≤ 250 mm em X e Y).
- Peças maiores que o volume útil devem ser divididas em partes com encaixe, pino ou parafuso.

## Ferramenta

Use **OpenSCAD** (preferência) ou, se a geometria for complexa demais para OpenSCAD (filetes, superfícies orgânicas), **build123d / CadQuery** em Python.

Antes do primeiro modelo, confira se o OpenSCAD está instalado:

```powershell
& "C:\Program Files\OpenSCAD\openscad.exe" --version
```

Se não estiver, peça permissão ao Gabriel e instale com `winget install OpenSCAD.OpenSCAD`.

Comandos úteis (PowerShell):

```powershell
$scad = "C:\Program Files\OpenSCAD\openscad.exe"

# exportar STL (use --backend=manifold se a versão suportar; é muito mais rápido)
& $scad -o model.stl model.scad

# gerar preview PNG para conferir visualmente
& $scad -o preview.png --imgsize=1024,768 --autocenter --viewall --colorscheme=Tomorrow model.scad

# sobrescrever um parâmetro sem editar o arquivo
& $scad -o model.stl -D "width=80" model.scad
```

## Estrutura de pastas

```
C:\writechoice\3D\
├── CLAUDE.md
├── modelos\        ← modelos criados por você (um subfolder por modelo)
├── projetos\       ← .3mf do Bambu Studio (Gabriel salva aqui depois de fatiar)
├── produtos\       ← itens à venda: modelo + 3mf + fotos
└── testes\         ← calibrações e impressões de teste
```

Cada modelo novo fica em `modelos\<nome-do-modelo>\` (kebab-case, em português, ex.: `suporte-fone`, `caixa-com-tampa`):

```
modelos\suporte-fone\
├── suporte-fone.scad     ← fonte paramétrica
├── suporte-fone.stl      ← (ou várias: suporte-fone-base.stl, suporte-fone-tampa.stl)
├── preview.png
└── README.md             ← o que é, medidas, como imprimir
```

Nunca sobrescreva um modelo existente sem perguntar; para uma nova versão, crie `-v2` ou atualize mantendo o histórico no README.

## Fluxo de trabalho

1. **Entender o pedido.** Se faltar uma medida essencial (ex.: tamanho do objeto que vai encaixar), pergunte antes. Se o resto for detalhe, escolha um valor razoável e diga qual escolheu.
2. **Escrever o `.scad` paramétrico.** Todos os valores ajustáveis como variáveis no topo do arquivo, com comentário curto e unidade (mm). Nada de número mágico no meio da geometria.
3. **Gerar o preview PNG e olhar a imagem** para confirmar que a forma está certa. Corrija antes de seguir.
4. **Exportar o STL** e conferir que a exportação não deu erro nem aviso de geometria não-manifold.
5. **Escrever o README.md** do modelo com: descrição, dimensões finais, parâmetros principais, orientação na mesa e configurações sugeridas de impressão (ver abaixo).
6. **Resumir para o Gabriel** em poucas linhas: o que foi criado, onde está e qualquer suposição que você fez.

## Regras de projeto para FDM

Projete pensando na impressão, não só na forma:

- **Base plana.** A peça deve ter uma face plana e grande para apoiar na mesa, na orientação de impressão.
- **Overhangs ≤ 45°.** Evite partes em balanço; prefira chanfros de 45° a arredondamentos embaixo. Se precisar de suporte, avise no README.
- **Pontes** (bridges) horizontais curtas, até ~20 mm, são aceitáveis.
- **Paredes:** mínimo de 1,2 mm (3 linhas de 0,4 mm); para peças estruturais, 2–3 mm.
- **Furos horizontais:** use formato de gota (teardrop) ou topo chanfrado para imprimir sem suporte.
- **Folgas de encaixe:** 0,2 mm para encaixe justo, 0,3–0,4 mm para encaixe deslizante/tampa. Deixe a folga como parâmetro (`clearance`).
- **Furos para parafuso:** some 0,2–0,3 mm ao diâmetro nominal (ex.: M3 → 3,3 mm). Para porca, use cavidade hexagonal com folga.
- **Primeira camada:** chanfro de 0,4–0,6 mm nas arestas inferiores para compensar o "pé de elefante".
- **Texto em relevo/baixo-relevo:** altura mínima de ~5 mm e profundidade de 0,6–1 mm; prefira fontes sem serifa e em negrito.
- **Resistência:** a peça é mais fraca entre camadas (eixo Z). Oriente para que o esforço principal fique no plano XY.
- **Multicor (AMS lite):** se o pedido envolver cores, separe cada cor em um STL próprio com o mesmo ponto de origem, para o Gabriel atribuir os filamentos no Bambu Studio.
- **Resolução de curvas:** use `$fn` adequado (ex.: 64–128 para cilindros visíveis), definido como parâmetro.

## Configurações sugeridas (para o README)

Padrão, a menos que o modelo exija outra coisa:

- Material: PLA
- Altura de camada: 0,2 mm (0,12–0,16 mm para detalhes finos)
- Paredes: 3
- Infill: 15% (peças decorativas) a 30–40% (peças funcionais), padrão gyroid
- Suporte: não, se o modelo seguir as regras acima
- Brim: só se a base for pequena ou alta e estreita

## Fluxo foto → peça

Quando o pedido partir de uma foto (pet, pessoa, objeto, logo do próprio cliente), escolha um dos três tipos abaixo. Se o Gabriel não disser qual, pergunte, mostrando as opções em uma linha cada.

Em todos os casos:

- Guarde a foto original em `modelos\<nome>\fonte\`.
- **Fotos de clientes não vão para o git.** Garanta que `fonte/` esteja no `.gitignore` antes de salvar qualquer foto.
- Dependências Python (instale com permissão): `pip install pillow numpy opencv-python trimesh rembg`.
- Mostre um **preview** (PNG) da etapa intermediária (contorno, cores separadas) e espere o OK do Gabriel antes de gerar o STL final, porque o resultado depende muito da foto.

### 1. Litofania

A foto vira uma placa em relevo: partes escuras ficam grossas, partes claras ficam finas, e a imagem aparece com luz atrás.

- Gere com um script Python (`make_lithophane.py`) que converte a imagem em tons de cinza num heightmap e exporta STL com `trimesh`.
- Parâmetros (no topo do script): largura (padrão 100 mm), espessura mínima 0,8 mm, espessura máxima 3,0 mm, moldura de 3 mm, formato (plana ou curva), resolução (~0,2 mm por pixel).
- Antes de converter: recorte para o enquadramento desejado, aumente o contraste e converta para tons de cinza.
- Impressão sugerida (README): PLA **branco**, camada 0,12 mm, infill 100%, imprimir **em pé** com brim, velocidade reduzida.

### 2. Silhueta / contorno

O contorno do objeto da foto vira uma peça plana extrudada: chaveiro, tag de coleira, placa com nome, quadro de parede, cortador de biscoito.

- Remova o fundo com `rembg` (ou limiarização, se o fundo for liso).
- Extraia o contorno com OpenCV (`findContours`), suavize e simplifique (`approxPolyDP`) e elimine detalhes menores que 1 mm.
- Gere o `.scad` com o contorno como `polygon()` (ou exporte SVG e use `import()`), e aplique `linear_extrude()`.
- Parâmetros: tamanho final (maior lado), espessura (3–4 mm), texto opcional, argola (furo de 4–5 mm com parede de 2 mm), contorno externo/offset.
- Cortador de biscoito: parede de 0,8–1,2 mm, altura 12–15 mm, aba de 5 mm no topo para firmeza. Lembre que **não** é seguro para contato com alimentos (ver Cuidados); sugira uso só para marcar, ou peça de inox.

### 3. Relevo multicor (AMS lite)

A foto simplificada em 2 a 4 cores, cada cor em uma camada de altura diferente.

- Reduza a imagem para **no máximo 4 cores** (k-means no OpenCV), já que o AMS lite tem 4 slots. Mostre a imagem posterizada para aprovação.
- Cada cor vira um STL separado (`<nome>-cor1.stl`, `<nome>-cor2.stl`…) com **o mesmo ponto de origem**, empilhados: base de 1,0 mm + 0,6 mm por camada de cor.
- No README, liste qual STL corresponde a qual cor, para atribuir os filamentos no Bambu Studio.

### Escultura 3D realista (fora do escopo)

Uma figura 3D realista a partir de foto não sai bem com OpenSCAD nem com scripts. Explique isso e sugira uma ferramenta de IA de imagem para 3D (ex.: as do MakerLab no MakerWorld, Meshy, Tripo). Depois que o Gabriel tiver o STL, você pode **finalizar**: corrigir a malha com `trimesh`, ajustar a escala, cortar a base plana e adicionar um pedestal com nome.

## Cuidados

- **Contato com alimentos:** peças impressas não são seguras para contato direto com comida (camadas acumulam bactérias, PLA não aguenta água quente). Se o pedido for pote, prato, tigela de pet etc., proponha uma **base/suporte para um recipiente de inox ou vidro** comprado pronto e explique o motivo. Nunca descreva uma peça como "própria para alimentos".
- **Peças para venda:** não reproduza produtos, logos ou personagens protegidos de marcas; crie designs originais.
- **Segurança:** não crie armas, peças de armas ou acessórios para armas.
