#!/bin/bash

# Limpeza garantida na saída do script, inclusive em SIGINT (Ctrl+C)
cleanup() {
  dialog --clear
  reset
  clear
}
trap cleanup EXIT

# Função: Valida mensagem de commit conforme Conventional Commits
function validate_commit_msg() {
  local msg="$1"
  local regex="^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\([a-zA-Z0-9_-]+\))?: .{1,72}$"
  [[ "$msg" =~ $regex ]]
}

# Menu principal
while true; do
  choice=$(dialog --clear --backtitle "Git Helper com Boas Práticas" \
    --title "Menu Principal" \
    --menu "Escolha uma operação:" 15 60 6 \
    1 "Clonar repositório (primeira vez)" \
    2 "Puxar atualizações (pull)" \
    3 "Comitar alterações (com validação)" \
    4 "Enviar alterações (push)" \
    5 "Sair" \
    3>&1 1>&2 2>&3)

  clear

  case $choice in
    1)
      dialog --msgbox "🔁 CLONAR:\n\nUse essa opção para clonar um repositório remoto pela primeira vez.\n\nExemplo:\nhttps://github.com/seu-usuario/seu-repo.git" 10 60
      repo_url=$(dialog --inputbox "Informe a URL do repositório para clonar:" 8 60 3>&1 1>&2 2>&3)
      clear
      git clone "$repo_url"
      read -p "Pressione ENTER para continuar..." ;;
      
    2)
      dialog --msgbox "📥 PUXAR:\n\nAtualiza seu repositório local com as últimas alterações do repositório remoto.\n\nComando usado internamente:\ngit pull" 10 60
      git pull
      read -p "Pressione ENTER para continuar..." ;;
      
    3)
      git status > /tmp/gitstatus.txt
      dialog --textbox /tmp/gitstatus.txt 20 70

      dialog --yesno "Deseja adicionar todos os arquivos modificados com 'git add .'?" 7 50
      if [[ $? -eq 0 ]]; then
        git add .
      else
        dialog --msgbox "Adicione os arquivos manualmente com:\n\n git add <arquivo>" 8 50
        continue
      fi

      tipos="feat fix docs style refactor test chore build ci perf revert"
      exemplos=$(cat <<EOF
Exemplos de mensagens de commit válidas:

  feat: adicionar funcionalidade X
  fix(login): corrigir bug no login
  docs(readme): atualizar instruções
  refactor(core): limpar função de cálculo
EOF
)
      dialog --msgbox "📐 MENSAGEM DE COMMIT\n\nFormato: <tipo>(escopo opcional): descrição curta\n\nTipos válidos:\n$tipos\n\n$exemplos" 20 70

      while true; do
        commit_msg=$(dialog --inputbox "Digite a mensagem de commit:" 8 60 3>&1 1>&2 2>&3)
        if validate_commit_msg "$commit_msg"; then
          dialog --msgbox "✅ Mensagem válida." 6 40
          git commit -m "$commit_msg"
          dialog --msgbox "✅ Commit realizado com sucesso." 6 40
          break
        else
          dialog --msgbox "❌ Mensagem inválida!\n\nSiga o padrão: tipo(escopo): descrição\nExemplo: feat(login): adicionar validação" 10 60
        fi
      done ;;
      
    4)
      dialog --msgbox "🚀 PUSH:\n\nEnvia seus commits locais para o repositório remoto.\n\nExemplo:\nmain (padrão), dev, feature/nova-tela" 10 60
      branch=$(dialog --inputbox "Para qual branch deseja enviar? (padrão: main)" 8 50 3>&1 1>&2 2>&3)
      branch=${branch:-main}
      git push origin "$branch"
      dialog --msgbox "✅ Push enviado para a branch '$branch'." 6 50 ;;
      
    5)
      dialog --infobox "Encerrando..." 3 30
      sleep 1
      exit 0 ;;

      
    *)
      dialog --msgbox "❌ Opção inválida. Tente novamente." 6 40 ;;
  esac
done
