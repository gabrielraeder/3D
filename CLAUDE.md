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

Há duas ferramentas de modelagem. **Você escolhe** a melhor para cada pedido, sem esperar o Gabriel mandar, e diz em uma linha qual usou e por quê.

| Use **text-to-cad** (plugin, build123d em Python) quando… | Use **OpenSCAD** quando… |
| --- | --- |
| a peça tem filetes/arredondamentos, lofts, cascas ou superfícies curvas | a peça é prismática e simples (caixa, espaçador, suporte reto, gabarito) |
| são várias peças que encaixam (gaveta + trilho, tampa + caixa, dobradiça) e vale checar interferência e folga | é uma edição ou nova versão de um modelo que já está em `.scad` (não migre sem motivo) |
| há mecanismo (dobradiça, corrediça, pino girando) e vale medir o curso | é o fluxo foto → silhueta (o contorno vira `polygon()`) |
| a peça aguenta carga e a pergunta "vai aguentar?" importa (ver `fea` abaixo) | a mudança é só trocar um parâmetro (`-D "width=80"`) |
| precisa partir de um STEP de fabricante, entregar STEP ou fazer desenho técnico | |

Se o pedido cair nas duas colunas, prefira o text-to-cad em peças novas e o OpenSCAD em modelos `.scad` existentes. Fluxos de foto (litofania, relevo multicor) continuam como scripts Python próprios (ver "Fluxo foto → peça").

### text-to-cad (skill `text-to-cad:cad`)

- Carregue o skill `text-to-cad:cad` e siga as instruções dele (modelo = função `@model`, `cad run` reconstrói, `cad model export` gera arquivos). Confira `cad --version` antes do primeiro uso na conversa.
- O script fica na pasta do modelo, com nome em snake_case (importável): `modelos\suporte-fone\suporte_fone.py`. Parâmetros como constantes ou argumentos de uma função helper no topo, em mm, com comentário curto.
- Declare o material de cada peça como PLA impresso em FDM (`plastics.pla(process=fdm(layer_height_mm=0.2))`), e no docstring do módulo coloque a linha `Check:` com o comando de DFM (abaixo), para toda edição rodar a mesma checagem.
- Depois do primeiro `cad run` que der certo, mostre ao Gabriel o link `view:` do CAD Viewer (ele atualiza a cada run).
- Comandos úteis:

```powershell
cad run modelos\suporte-fone\suporte_fone.py                      # reconstrói; imprime id e link view:
cad model snapshot $ID modelos\suporte-fone\preview.png --preview  # preview PNG
cad model dfm $ID --process printing --technology fdm --material pla --build-volume 256x256x256
cad model interference $ID                                         # montagens: peças não se sobrepõem
cad model export $ID modelos\suporte-fone\suporte-fone.stl --tolerance 0.02   # ~1/10 da menor folga
```

### Outros skills do plugin: use quando fizer sentido

- **`text-to-cad:fea`**: peça estrutural com carga conhecida (prateleira, gancho, suporte de parede, braço em balanço). Rode se o Gabriel informar a carga ou se ela for óbvia pelo pedido. Se não, ofereça. Coloque o resultado (fator de segurança, deflexão) no README.
- **`text-to-cad:engineering-drawing`**: só quando pedirem desenho técnico/PDF com cotas.
- **`text-to-cad:render`**: imagens fotorrealistas, útil para os itens de `produtos\` (anúncio, foto de capa). Só quando pedirem ou para produto à venda.
- **`text-to-cad:print3d`** (fatiar no OrcaSlicer): **não use por padrão**, porque o Gabriel fatia no Bambu Studio. Só se ele pedir. Nunca inicie uma impressão.

### Checagem de impressão (vale para as duas ferramentas)

Todo STL final passa pela checagem de DFM do plugin, mesmo que tenha vindo do OpenSCAD:

```powershell
cad stl dfm modelos\suporte-fone\suporte-fone.stl --process printing --technology fdm --material pla --build-volume 256x256x256
```

- `FAILED` (exit 1): corrija antes de entregar. `NOT CHECKED` (exit 3) **não** é aprovação: resolva o motivo (malha aberta etc.).
- Avisos: corrija se não mudar o que foi pedido; senão, cite no README.
- O checador julga a peça **na orientação do arquivo** (base em Z=0). Exporte o STL já na orientação de impressão; se não for possível, avise no README e rode com `--candidates` para ver a melhor orientação.
- As regras do checador são genéricas. Quando divergirem das "Regras de projeto para FDM" abaixo (ex.: tamanho de ponte), **valem as regras deste arquivo**, que já foram testadas na A1.

### OpenSCAD

Antes do primeiro modelo em OpenSCAD, confira se está instalado:

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
├── suporte-fone.scad     ← fonte paramétrica (OpenSCAD), ou
├── suporte_fone.py       ← fonte paramétrica (text-to-cad / build123d)
├── suporte-fone.stl      ← (ou várias: suporte-fone-base.stl, suporte-fone-tampa.stl)
├── preview.png
└── README.md             ← o que é, medidas, ferramenta usada, como imprimir
```

Arquivos temporários (snapshots de conferência, scripts de checagem) vão para o scratchpad da sessão, não para a pasta do modelo.

Nunca sobrescreva um modelo existente sem perguntar; para uma nova versão, crie `-v2` ou atualize mantendo o histórico no README.

## Fluxo de trabalho

1. **Entender o pedido.** Se faltar uma medida essencial (ex.: tamanho do objeto que vai encaixar), pergunte antes. Se o resto for detalhe, escolha um valor razoável e diga qual escolheu.
2. **Escolher a ferramenta** pela tabela em "Ferramenta" e dizer qual foi.
3. **Escrever o modelo paramétrico** (`.scad` ou `.py`). Todos os valores ajustáveis como variáveis/constantes no topo do arquivo, com comentário curto e unidade (mm). Nada de número mágico no meio da geometria.
4. **Gerar o preview PNG e olhar a imagem** para confirmar que a forma está certa. Com text-to-cad, mande também o link do CAD Viewer. Em montagens, rode `cad model interference`. Corrija antes de seguir e **espere o OK do Gabriel** antes de exportar.
5. **Exportar o STL** e conferir que a exportação não deu erro nem aviso de geometria não-manifold.
6. **Rodar a checagem de DFM** no STL (ver "Checagem de impressão") e, se a peça for estrutural, considerar o `fea`.
7. **Escrever o README.md** do modelo com: descrição, ferramenta usada, dimensões finais, parâmetros principais, orientação na mesa, resultado da checagem (avisos que ficaram) e configurações sugeridas de impressão (ver abaixo).
8. **Resumir para o Gabriel** em poucas linhas: o que foi criado, onde está, a ferramenta escolhida, o resultado das checagens e qualquer suposição que você fez.

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
- **Resolução de curvas:** no OpenSCAD, use `$fn` adequado (ex.: 64–128 para cilindros visíveis), definido como parâmetro. No text-to-cad, a geometria é exata e a resolução vem do `--tolerance` do export (~1/10 da menor folga; 0,02 mm é um bom padrão).

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

Uma figura 3D realista a partir de foto não sai bem com OpenSCAD nem com scripts. Explique isso e sugira uma ferramenta de IA de imagem para 3D (ex.: as do MakerLab no MakerWorld, Meshy, Tripo). Depois que o Gabriel tiver o STL, você pode **finalizar**: corrigir a malha com `trimesh`, ajustar a escala, cortar a base plana e adicionar um pedestal com nome (o pedestal pode ser um modelo text-to-cad que lê a malha com `stl.read`). Rode a checagem de DFM no resultado: malhas geradas por IA costumam vir abertas.

## Cuidados

- **Contato com alimentos:** peças impressas não são seguras para contato direto com comida (camadas acumulam bactérias, PLA não aguenta água quente). Se o pedido for pote, prato, tigela de pet etc., proponha uma **base/suporte para um recipiente de inox ou vidro** comprado pronto e explique o motivo. Nunca descreva uma peça como "própria para alimentos".
- **Peças para venda:** não reproduza produtos, logos ou personagens protegidos de marcas; crie designs originais.
- **Segurança:** não crie armas, peças de armas ou acessórios para armas.
