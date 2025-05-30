#!/bin/bash

function show_menu() {
  echo "======================"
  echo " Git Helper Menu"
  echo "======================"
  echo "1. Clonar repositório (primeira vez)"
  echo "2. Puxar atualizações (pull)"
  echo "3. Comitar alterações"
  echo "4. Enviar alterações (push)"
  echo "5. Sair"
  echo "======================"
  read -p "Escolha uma opção: " choice
}

function clone_repo() {
  echo ""
  echo "🔁 CLONAR: Copia um repositório remoto pela primeira vez para sua máquina."
  read -p "Digite a URL do repositório para clonar: " repo_url
  git clone "$repo_url"
}

function pull_repo() {
  echo ""
  echo "📥 PUXAR: Atualiza o repositório local com as últimas alterações do repositório remoto."
  git pull
}

function validate_commit_msg() {
  local msg="$1"
  local regex="^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\([a-zA-Z0-9_-]+\))?: .{1,72}$"
  if [[ "$msg" =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

function commit_changes() {
  echo ""
  echo "💾 COMITAR: Registra as alterações locais com uma mensagem padronizada."

  git status

  read -p "Deseja adicionar todos os arquivos modificados? (s/n): " add_all
  if [[ $add_all == "s" ]]; then
    git add .
  else
    echo "Adicione os arquivos manualmente com 'git add <arquivo>' e tente novamente."
    return
  fi

  echo ""
  echo "📐 Use o formato convencional para o commit:"
  echo "  tipo(escopo opcional): descrição"
  echo ""
  echo "🔧 Tipos válidos: feat, fix, docs, style, refactor, test, chore, build, ci, perf, revert"
  echo "💡 Exemplo: feat(login): adicionar validação de token"

  while true; do
    read -p "Digite a mensagem de commit: " commit_msg
    if validate_commit_msg "$commit_msg"; then
      echo "✅ Mensagem válida."
      break
    else
      echo "❌ Mensagem inválida. Siga o padrão: tipo(escopo opcional): descrição curta"
    fi
  done

  read -p "Confirmar commit? (s/n): " confirm
  if [[ $confirm == "s" ]]; then
    git commit -m "$commit_msg"
    echo "✅ Commit realizado com sucesso."
  else
    echo "❌ Commit cancelado."
  fi
}

function push_repo() {
  echo ""
  echo "🚀 PUSH: Envia seus commits locais para o repositório remoto."
  read -p "Deseja enviar para qual branch? (padrão: main): " branch
  branch=${branch:-main}
  git push origin "$branch"
}

# Loop principal
while true; do
  show_menu
  case $choice in
    1) clone_repo ;;
    2) pull_repo ;;
    3) commit_changes ;;
    4) push_repo ;;
    5) echo "Saindo..."; exit 0 ;;
    *) echo "Opção inválida." ;;
  esac
  echo ""
done
