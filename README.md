# SCRIPT – Painel Contadores (FiveM)

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-FiveM-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-f40552?style=for-the-badge&logo=fivem&logoColor=white)


Painel **NUI moderno em tema BLACK**, desenvolvido para **FiveM**, exibindo **contadores dinâmicos** de Staff, Polícia e Ilegal, com visual limpo, profissional e totalmente personalizável.

Ideal para servidores que querem **organização**, **estética premium** e **leitura rápida de informações** dentro do jogo.

---

## 🖼️ Preview

![Preview do Script](https://i.postimg.cc/FK5yTH69/image.png)

---

## 📦 Tecnologias Utilizadas

* **HTML5** – Estrutura da interface
* **CSS3** – Estilização (tema black moderno)
* **JavaScript** – Atualização dinâmica dos dados
* **FiveM NUI** – Integração com o servidor

---

## 📁 Estrutura do Script

```
Admin-Panel/
├── cfg/
├── nui/
├── README.md
├── client.lua
├── fxmanifest.lua
├── server.lua
```

---

## 📥 Instalação

1. Coloque a pasta do script dentro de:

```
resources/
```

2. No `server.cfg`, adicione:

```
ensure nome_do_script
```

3. Reinicie o servidor ou use:

```
refresh
start nome_do_script
```

---

## ⚙️ Configuração

### 🎨 Alterar cores dos contadores

As cores são controladas diretamente no **HTML**, facilitando a personalização:

```html
<div class="barra1" style="background: rgb(34, 197, 94);"></div>
<div class="barra2" style="background: rgb(34, 197, 94);"></div>

<div class="info-contador" style="color: rgb(34, 197, 94);">16</div>
```

Basta alterar os valores **RGB** para a cor desejada.

---

### 🔢 Atualizar valores dinamicamente

Os valores podem ser atualizados via **JavaScript** ou **client.lua**, usando `SendNUIMessage`.

Exemplo:

```lua
SendNUIMessage({
    action = "updateStaff",
    value = 16
})
```

---

## 🛠️ Funcionalidades

* Painel NUI em **tema black**
* Contadores independentes
* Visual moderno e limpo
* Fácil personalização de cores
* Integração direta com FiveM
* Leve e otimizado
* Compatível com qualquer base

---

## ⚡ Desempenho

* Interface leve
* Baixo consumo de recursos
* Atualizações apenas quando necessário
* Ideal para servidores médios e grandes

---

## 🔐 Segurança

* Não expõe dados sensíveis
* Comunicação controlada via NUI
* Nenhuma dependência externa

---

## 📄 Licença

Uso permitido para **servidores FiveM**.
Proibida a **revenda**, **redistribuição** ou **vazamento** sem autorização do autor.

---

## ❤️ Créditos

Desenvolvido por **Athilio**
Design e conceito voltados para **painéis administrativos modernos**
