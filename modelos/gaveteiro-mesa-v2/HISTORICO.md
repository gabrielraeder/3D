# Histórico do projeto: gaveteiro sob a mesa

Contexto para continuar o projeto em outra sessão.

**Organização:** cada versão fica numa subpasta (`v2.1/`, `v2.2/`…) com o seu `.scad`, STLs, previews e README. Para uma versão nova, crie uma pasta nova e não altere as anteriores. A versão atual é a **[v2.3](v2.3/)**: os detalhes de uso e montagem estão no [README dela](v2.3/README.md), e a fonte é [gaveteiro-mesa-v2.3.scad](v2.3/gaveteiro-mesa-v2.3.scad), em OpenSCAD 2021.01.

## Situação atual (20/11/2026)

- O **teste de encaixe v2.1 passou**: o braço desliza bem no trilho e a trava funciona.
- A **v2.2** engrossou a alma do trilho de 2,5 para 4 mm, depois da análise de tensão.
- A **v2.3** fechou a treliça nos topos dos trilhos e encurtou os trilhos (frente 140 mm, laterais 100 mm). A canaleta não mudou desde a v2.1, então o teste de encaixe continua valendo.
- **Próximo passo:** imprimir os trilhos da frente e a gaveta da frente da v2.3. Os STLs estão prontos em `v2.3/`.
- As gavetas laterais ainda não foram impressas nem exportadas na v2.3.
- O MDF já chegou: 15 × 21 cm, 3 mm, medida exata.

## O espaço na mesa

- Fica embaixo do tampo, do lado esquerdo do pé preto da mesa.
- **170 mm** da borda lateral do tampo até a face da haste do pé.
- A profundidade da mesa é de **800 mm**.
- A haste tem uma **aba metálica**:
  - 25 mm de largura a partir da haste;
  - desce 7 mm abaixo do tampo;
  - termina a 60 mm das bordas da frente e de trás.
- Fixação com parafusos no tampo.
- A altura é livre, porque o Gabriel não fica sentado nessa posição.

## Evolução do projeto

1. **v1: carcaças fechadas com gavetas** (pasta `modelos/gaveteiro-mesa/`).
   - Tinha rebaixo para a aba.
   - Gastava ~2,5 kg de PLA, e só a carcaça da frente tinha 486 g e 11 h. **Foi descartada pelo custo.**
   - O Gabriel pediu para apagar essa pasta, mas a remoção foi bloqueada pela permissão. Ela ainda existe.
2. **v2: sem carcaça.**
   - Cada gaveta corre num par de trilhos parafusado no tampo, e o fundo é uma placa de MDF solta, apoiada numa moldura.
   - São três gavetas: **uma na frente**, que abre para a frente, só a gaveta, sem divisórias de canetas; e **duas laterais**, que abrem para a borda lateral.
   - O conjunto gasta ~700 g.
3. **v2.1: correções depois do 1º teste de encaixe.** O primeiro teste falhou: saiu justo demais e nem deslizava, com bolhas e fiapos nas pontas finas a 45°.
   - Causa: pontas em lâmina a 45° e faces de deslize viradas para baixo, que cedem na impressão e comem a folga.
   - Correções:
     - os trilhos passaram a imprimir **em pé**, o que deixa o perfil 2D por camada, sem balanço;
     - as travessas entre os trilhos viraram **treliça a 45°**;
     - a ponta do braço ficou achatada;
     - `slide_clear` subiu de 0,3 para **0,5 mm**;
     - `bump_h` subiu de 0,8 para **1,0 mm**;
     - os furos ganharam formato de gota.
   - O segundo teste passou.
4. **v2.2: validação com o plugin text-to-cad (20/11/2026).**
   - A checagem de impressão (`cad stl dfm`) passou nos trilhos e na gaveta da frente.
   - A FEA (CalculiX) com 2 kg e a gaveta aberta 70% mostrou que o trilho é o elo mais flexível. A alma de 2,5 mm flexiona, e a ponta da placa de baixo cede 1,31 mm na boca.
   - Mudança: `web_t` de 2,5 para **4 mm**. A ponta passa a ceder 0,58 mm, e a tensão na alma cai pela metade.
   - Na gaveta, a tensão fica entre 2 e 6 MPa. O único pico é num canto vivo no topo da parede de trás (~27 MPa, ponto singular), que vale observar.
   - Render: `v2.1/render-gaveta-frente.png`. Os números completos estão no README da v2.2.
   - Ferramenta: o `cad` e o `uv` ficam em `~/.local/bin`, que não está no PATH. Use `export PATH="$HOME/.local/bin:$PATH"`.
5. **v2.3: treliça fechada e trilhos curtos (20/11/2026).**
   - O Gabriel notou que o zigue-zague terminava "no ar", com diagonais cortadas na ponta de cima. Agora o passo é ajustado ao comprimento, e o padrão termina nos topos dos dois trilhos, com diagonais a 45° ou mais inclinadas.
   - Ideias descartadas:
     - barra no fundo: com o trilho em pé, seria uma ponte de ~122 mm no topo da peça;
     - imprimir só as barras das pontas, ou cada trilho separado: os trilhos ficariam soltos durante a impressão, e a instalação exigiria gabarito. A treliça é só ~14 g do par.
   - Trilhos encurtados: frente de 210 para **140 mm**, laterais de 140 para **100 mm**. Com a gaveta aberta, o braço só usa ~62 mm (frente) ou ~44 mm (laterais) do trilho; com ela fechada, o dente segura a frente se o peso estiver no fundo.
   - Economia: ~33 g no par da frente e ~18 g em cada lateral (~70 g no conjunto). A impressão em pé também fica mais baixa e estável. São 2 parafusos por trilho, 12 no total.

## Como funciona o mecanismo

- O topo das paredes laterais da gaveta dobra a 45° para dentro, formando um **braço**.
- O braço desliza numa canaleta a 45° do trilho, apoiado na **placa de baixo**.
- Os dois lados são espelhados, então a gaveta não cai nem escapa de lado. Ela só sai deslizando pela ponta.
- Na entrada do trilho, uma placa de cima curta (o **dente**, de 30 mm) segura o braço quando a gaveta está aberta, para ela não tombar.
- Um **ressalto** no braço trava no dente quando a gaveta abre 70%. Um puxão firme solta.
- A frente da gaveta encosta na ponta dos trilhos e serve de batente ao fechar.
- O par de trilhos é **uma peça só**, ligada pela treliça. Isso garante a distância e o paralelismo na instalação.
- Os trilhos são mais curtos que a gaveta (v2.3). Com a gaveta fechada, o fundo dela passa além do fim dos trilhos.
- O trilho do lado da haste fica todo na madeira, a 1 mm da aba. A gaveta passa por baixo da aba, ficando a pelo menos 9 mm do tampo.

## Peças (STLs já exportados e conferidos como sólido único)

**v2.3 (atual), em `v2.3/`:**

| Arquivo | Qtd. | Tamanho (mm) | Peso | Orientação |
|---|---|---|---|---|
| `gaveteiro-mesa-v2.3-trilhos-frente.stl` | 1 | 149 × 30 × **140 em pé** | ~65 g (estimado) | em pé, ponta do dente na mesa, brim só externo de 5 mm |
| `gaveteiro-mesa-v2.3-gaveta-frente.stl` | 1 | 154 × 215 × 109 | 160 g | apoiada no fundo, frente virada para a frente da mesa da impressora |

**v2.2, em `v2.2/`:** trilhos da frente com 210 mm e a mesma gaveta. Foi substituída pela v2.3.

**v2.1, em `v2.1/`, com alma de 2,5 mm.** As laterais ainda não foram geradas na v2.3.

| Arquivo | Qtd. | Tamanho (mm) | Peso | Orientação |
|---|---|---|---|---|
| `gaveteiro-mesa-v2-teste-encaixe.stl` | 1 | 84 × 50 × 50 | 14 g | já testado, aprovado |
| `gaveteiro-mesa-v2-trilhos-frente.stl` | 1 | 149 × 30 × **210 em pé** | 86 g | substituído pela v2.3 |
| `gaveteiro-mesa-v2-gaveta-frente.stl` | 1 | 154 × 215 × 109 | 160 g | igual à v2.3 |
| `gaveteiro-mesa-v2-trilhos-lateral.stl` | 2 | 209 × 30 × **140 em pé** | 61 g | gerar de novo pela v2.3 |
| `gaveteiro-mesa-v2-gaveta-lateral.stl` | 2 | 214 × 155 × 109 | 165 g | apoiada no fundo |

Para gerar uma peça: `openscad -o x.stl -D 'part="front_drawer"' gaveteiro-mesa-v2.3.scad`.

Valores de `part`: `assembly`, `section`, `front_drawer`, `front_rails`, `side_drawer`, `side_rails`, `fit_test`.

A versão 2021.01 do OpenSCAD não tem o backend manifold. Para checar se a peça é um sólido fechado, use `--render`.

## Parâmetros principais

- **Espaço na mesa:** `space_width=170`, `bracket_width=25`, `bracket_drop=7`, `desk_depth=800`.
- **Painel de MDF:** `panel_w=150`, `panel_l=210`, `panel_t=3`, `panel_clear=0.5`.
- **Gaveta:**
  - `hang_depth=110`, a distância do tampo ao fundo; a altura externa da gaveta fica em 109;
  - `wall=1.6`;
  - `corner_r=2`.
- **Perfil do trilho:** `top_clear=9`, `plate_t=2.4`, `arm_t=2.0`, `slide_clear=0.5`, `arm_reach=12`, `web_t=4` (v2.2; era 2,5).
- **Comprimento dos trilhos (v2.3):** `front_rail_max=140`, `side_rail_max=100`. Um `assert` barra comprimentos menores que o fim do braço com a gaveta aberta mais 15 mm.
- **Trava:** `max_open_ratio=0.7`, `tooth_len=30`, `bump_h=1.0`.
- **Parafusos:** `screw_d=3.8`, para parafusos de madeira 3,5 × 16 mm de cabeça chata. São 12 no total, 2 por trilho (v2.3).

## Acabamento

- Os cantos são arredondados, com chanfro de 0,4 mm contra o pé de elefante, e a costura vai para a parede de trás.
- Foi criado o preset **"Gaveteiro - Acabamento"** no Bambu Studio, em `%APPDATA%\BambuStudio\user\<id>\process\`. As configurações:
  - base 0.16mm High Quality @BBL A1;
  - costura atrás;
  - scarf seam nas paredes externas;
  - parede externa a 50 mm/s;
  - Arachne;
  - sem suporte e sem brim.
- Não foi confirmado se o preset aparece depois de reiniciar o Bambu Studio.
- A recomendação é PLA fosco (matte).

## Pendências

- Imprimir os trilhos da frente e a gaveta da frente da v2.3. Instalar e testar com peso.
- Observar os cantos de trás no topo da gaveta (concentração de tensão apontada pela FEA).
- Gerar os STLs laterais da v2.3 quando for imprimir as laterais.
- Apagar `modelos/gaveteiro-mesa/` (v1), se o Gabriel liberar. Depois, talvez renomear a pasta v2.
- Confirmar o preset no Bambu Studio.
- Imprimir as gavetas laterais quando quiser.

## Preferências do Gabriel neste projeto

- Custo de filamento é prioridade: nada de carcaça maciça.
- O acabamento visual importa muito.
- Mostrar o preview e esperar o OK antes de exportar STL ou README.
- Não sobrescrever um modelo existente sem perguntar. **Cada versão nova vai numa subpasta própria** dentro de `gaveteiro-mesa-v2/` (`v2.4/`…), com o `.scad` e os STLs nomeados com a versão (`gaveteiro-mesa-v2.4-*.stl`), e fica registrada no Histórico do README e aqui.
