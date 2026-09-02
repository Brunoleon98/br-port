<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

# 💾 Save, Sincronização e Múltiplos Perfis

Política completa de save: slots, autosave, nuvem, conflitos e migração entre plataformas.

## 💾 Slots de save

**3 slots manuais + 1 autosave por perfil** — Cada perfil tem até 3 slots manuais (nomeáveis pelo jogador) + 1 slot de autosave atualizado a cada fim de turno. O autosave nunca é sobrescrito pelo jogador manualmente — é segurança contra crash. Total: 4 saves visíveis por perfil.

**Múltiplos perfis no mesmo dispositivo** — Até 4 perfis ativos por dispositivo (cada um com seus 4 slots, 16 saves no total). Útil para família que compartilha tablet. Um perfil ativo por padrão; criar ou alternar perfil fica em Configurações.

**Nome e timestamp visíveis** — Cada save mostra: nome do porto, fase atual, semana de jogo, dinheiro em caixa, momento do salvamento (data real + 'Há 2 horas'). Tela de seleção de save é folha de calendário do porto — não lista de dados.

## 💿 Política de autosave

**Quando acontece** — Após cada confirmação de 'Próximo dia'. Antes de eventos narrativos críticos (sessão da câmara, escolha de final). Ao fechar o app pelo botão 'Sair' do menu (não ao matar processo).

**Quando não acontece** — Durante uma decisão ainda não confirmada. Em meio a uma animação de processamento. Durante leilão aberto (autosave só após o leilão fechar). Isso evita salvar estados parciais.

**Recuperação de crash** — Se o app fechar inesperadamente, ao reabrir o jogo oferece: 'Encontramos um turno interrompido. Restaurar do ponto antes do crash, ou começar o novo turno do zero?' O jogador escolhe — sem perda de progresso anterior ao turno.

## ☁️ Sincronização com a nuvem

**Google Play Games + iCloud nativos** — Gratuito, sem backend próprio. Sincronização automática ao fechar cada sessão. Sem dependência de servidor proprietário — funciona mesmo se o estúdio parar de operar.

**Resolução de conflito cloud vs local** — Se houver conflito (jogador editou save local sem internet, depois sincroniza), o jogo apresenta os dois: 'Save local de 14h32 vs Save da nuvem de 09h15. Qual manter?'. Nunca sobrescreve automaticamente. Nunca soma — só substitui.

**Backup manual e exportação** — Configurações → Exportar Save → arquivo .brport-save compartilhável (e-mail, drive). Importação na mesma tela. Cobre migração entre plataformas (Android ↔ iOS) e backup para o jogador paranoico. Arquivo é texto JSON criptografado leve — não impede edição mas registra na carga (matérias da Bela podem mencionar 'algo estranho com os registros do porto').

## 📱 Cross-device migration UX

**Mesma plataforma** — Android → Android (mesma conta Google) ou iOS → iOS (mesma Apple ID): automático ao instalar e logar. Nenhuma ação do jogador necessária.

**Plataforma diferente** — Android → iOS ou vice-versa: o jogador exporta no dispositivo antigo (arquivo .brport-save), envia para si mesmo, importa no novo dispositivo. Tela de configurações tem botão grande 'Migrar para outro celular' com instruções passo a passo.

**Mensagem padrão de segurança** — Na tela de configurações: 'Seu progresso está salvo automaticamente na sua conta [Google Play / iCloud]. Você nunca precisa se preocupar em perder o porto.' Uma linha, sem jargão técnico.


---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
