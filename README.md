# Sinaliza

**Sinaliza** é um aplicativo educacional para iOS voltado ao reconhecimento de sinais manuais do alfabeto em Libras (Língua Brasileira de Sinais), utilizando a câmera frontal, visão computacional (`Vision`) e um modelo de machine learning baseado em SVM integrado via Core ML.

---

## Objetivo

Promover o aprendizado da Língua Brasileira de Sinais por meio de uma experiência interativa e gamificada, reforçando a prática do alfabeto manual com reconhecimento automático de gestos.

---

## Como funciona

1. O app sorteia uma letra do alfabeto.
2. O usuário realiza o sinal correspondente em Libras.
3. Após uma contagem regressiva, o app captura a imagem com a câmera frontal.
4. A biblioteca Vision detecta a pose da mão e extrai os pontos das juntas.
5. A imagem é convertida em atributos derivados (distâncias, ângulos, deslocamentos).
6. Os atributos são organizados como `MLMultiArray` e enviados ao modelo Core ML.
7. O modelo classifica o gesto e fornece uma predição com probabilidade associada.

---

## Tecnologias utilizadas

- [SwiftUI](https://developer.apple.com/xcode/swiftui/) — construção de interface moderna e declarativa
- [AVFoundation](https://developer.apple.com/documentation/avfoundation) — captura de imagem com a câmera frontal
- [Vision](https://developer.apple.com/documentation/vision) — detecção de pose da mão
- [Core ML](https://developer.apple.com/documentation/coreml) — execução local do modelo de aprendizado de máquina
- [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) — persistência de dados locais

---

## Versões utilizadas

| Componente       | Versão        |
|------------------|---------------|
| Xcode            | 16.4          |
| iOS SDK          | 18.5          |
| Swift            | 6.1.2         |
| Python           | 3.9           |
| coremltools      | 6.3.0         |
| scikit-learn     | 1.1.2         |
| numpy            | 1.24.4        |
| joblib           | 1.3.2         |
| Vision Framework | iOS 17+       |
| AVFoundation     | iOS 17+       |

---

## Modelo de Machine Learning

- O modelo foi treinado com base no conjunto de dados [cnn-libras](https://github.com/lucaaslb/cnn-libras), criado por **Lucas Lacerda** (2022), que disponibiliza imagens dos sinais do alfabeto manual da Libras para aplicações em visão computacional e aprendizado de máquina.
- Modelo treinado com `scikit-learn` (pipeline com `StandardScaler` + `SVC` com `probability=True`)
- Salvo em `.pkl` e convertido para `.mlpackage` com `coremltools`
- Entrada do modelo: vetor com 10 atributos derivados da posição da mão
- Saída: rótulo da letra (`classLabel`) e dicionário com probabilidades (`classProbability`)

---

## Funcionalidades

- Reconhecimento de letras em Libras com feedback imediato
- Contagem regressiva antes da captura
- Mensagens de feedback em caso de acerto, erro ou falha na leitura
- Sistema de pontuação e estrelas (1 estrela a cada 7 acertos)
- Repetição da letra em caso de falha na classificação
- Percorre todo o alfabeto sem repetições

---

## Requisitos

- Xcode 15 ou superior
- iOS 17 ou superior
- Câmera frontal ativa
- Modelo `svm_pipeline.mlpackage` incluído no projeto

---

## Estrutura futura planejada

- Inclusão de níveis com conjuntos temáticos de sinais
- Histórico de desempenho do usuário
- Modo livre e modo jogo
- Integrção com Game Center

---

## Licença

Este projeto está licenciado sob a **Creative Commons Atribuição-NãoComercial 4.0 Internacional (CC BY-NC 4.0)**.  
Você pode usá-lo, adaptá-lo e distribuí-lo para fins não comerciais, desde que atribua os devidos créditos.

---

## Autoria

Desenvolvido por **Ana Flávia Torres do Carmo** como parte de um projeto pessoal com propósito educacional e de acessibilidade.
