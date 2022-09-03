#!/bin/bash
# Para executar esse script, mude suas permissões com o comando
# $ chmod 770 testeQual.sh

disclaimer(){
    opt='N'
    echo -e "\t$RED************************************************************"
    echo -e "\t*  Este script é distribuído 'no estado em que se encontra'*"
    echo -e "\t*e sem garantias de qualquer tipo, expressas ou implícitas,*" 
    echo -e "\t*incluindo, mas não se limitando a qualquer garantia sobre *"
    echo -e "\t*a comercialização ou adequação a uma finalidade específica*"
    echo -e "\t*                                                          *"
    echo -e "\t*     Você deve assumir todo o risco em utilizá-lo         *"
    echo -e "\t************************************************************\n"
    read -p "Aceita continuar? [s,N] " opt
        if [[ $opt != 'S' && $opt != 's' ]]; then
            echo -e "$NORMAL"
            exit
        else
            echo -e "$NORMAL"
        fi
}

checkInstalation(){
    echo -e "Checando dependências..."
    erro=0
    for prog in "java" "python3.7" "pip" $EDITOR; do 
        echo -ne "\t- $prog .......\r"
        which $prog >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "\t- $prog .......$GREEN\t[OK] $NORMAL"
        else
            echo -e "\t- $prog .......$RED\t[FAIL] $NORMAL"
            erro=1
        fi
    done
    if [[ erro -eq 1 ]]; then
        echo -e "$RED *** Há dependências faltantes ***$NORMAL\n Por favor instale os pacotes$BLUE $EDITOR java, python3.7 e pip$NORMAL, e tente novamente\n"
        exit
    fi
}


#cores
RED="\033[1;31m"
GREEN=" \033[0;32m"
BLUE=" \033[0;34m"
NORMAL="\033[0m"

disclaimer
checkInstalation


echo "Quadro 2 - Criação de diretórios"
cd
mkdir -p $HOME/bin/BioInfoTools/Downloads

echo "Quadro 3 - Download e instalação do FastQC"
cd $HOME/bin/BioInfoTools/Downloads
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip -d ../ fastqc_v0.11.9.zip
chmod 755 ../FastQC/fastqc
export PATH=$PATH:$HOME/bin/BioInfoTools/FastQC/

fastqc --version
if [[ $? -eq 0 ]]; then
    echo -e "\t$GREEN FastQC instalado com sucesso!$NORMAL"
else
    echo -e "\t$RED*** Ocorreu um erro durante a instalação do FastQC***\n\t*** Verifique se sua máquina possui os requisitos necessários *** $NORMAL"
    exit
fi
echo
read -t 5 -n 1 -p "Pressione qualquer tecla para continuar..."
echo 
echo

echo "Quadro 4 - Instalação do MultiQC"
pip install multiqc --user
export PATH=$PATH:$HOME/.local/bin
multiqc --version
if [[ $? -eq 0 ]]; then
    echo -e "\t$GREEN MultiQC instalado com sucesso!$NORMAL"
else
    echo -e "\t$RED*** Ocorreu um erro durante a instalação do MultiQC ***\n\t*** Verifique se sua máquina possui os requisitos necessários *** $NORMAL"
    exit
fi

echo
read -t 5 -n 1 -p "Pressione qualquer tecla para continuar..."
echo 
echo

echo "Quadro 5 - Download dos arquivos de sequenciamento"
mkdir -p $HOME/analise/amostras
cd $HOME/analise/amostras
wget http://dunabioinfo.com/pt/blog/mc01/good.fastq.gz
wget http://dunabioinfo.com/pt/blog/mc01/bad.fastq.gz  
wget http://dunabioinfo.com/pt/blog/mc01/RNA-Seq.fastq.gz  
wget http://dunabioinfo.com/pt/blog/mc01/RRBS.fastq.gz  
#wget http://dunabioinfo.com/pt/blog/mc01/small_rna.fastq.gz


echo "Quadro 7 - Utilizando o FastQC em linha de comando"
mkdir -p $HOME/analise/resultados
cd $HOME/analise/amostras
fastqc -t 4 -o ../resultados/ $(ls *.fastq *.fastq.gz)

echo "Quadro 8 - Executando o MultiQC"
cd $HOME/analise/resultados/
mkdir MultiQC
multiqc -o MultiQC ./
cd MultiQC

read -n 1 -p "Deseja adicionar os caminhos do FastQC e MultiQC permanentemente ao PATH? [s,N]" opt
if [[ $opt == 's' || $opt == 'S' ]]; then
    echo 'export PATH=$PATH:$HOME/bin/BioInfoTools/FastQC/:$HOME/.local/bin' >> $HOME/.bashrc
    echo -e '\n\nAs novas configurações estarão disponíveis para novas sessões do bash.\n \nIniciando uma nova sessão para testes.\n\t Para encerrá-la digite <exit>. \n '
    /bin/bash
fi

echo 
