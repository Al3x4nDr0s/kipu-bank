## 🏦 Descripción del Contrato

**KipuBank** es un smart contract de tipo bancario que opera en la red de Ethereum, permitiendo a los usuarios depositar y retirar Ether (ETH) de manera segura. Este proyecto fue creado como requisito para la aprobacion del MODULO 2 del curso de ETHKIPU aplicando conceptos fundamentales de **Solidity**, patrones de seguridad en blockchain y buenas prácticas de desarrollo.

El contrato impone las siguientes reglas para garantizar la seguridad y la estabilidad:

* **Límite Global de Depósitos (`bankCap`)**: Máximo de ETH que el banco puede contener en total, establecido en el momento del despliegue.
* **Límite de Retiro por Transacción (`transactionWithdrawalCap`)**: Un límite fijo para la cantidad de ETH que se puede retirar en una sola transacción.
* **Cuentas Individuales**: Cada usuario tiene una cuenta personal (`vaults`) para almacenar sus fondos.

El contrato utiliza **errores personalizados**, **eventos** para rastrear las interacciones y sigue el patrón de seguridad **checks-effects-interactions** para prevenir vulnerabilidades comunes como ataques de reentrada.

---

## 🛠️ Requisitos de Pre-instalación

Para interactuar con este proyecto, necesitarás tener instalado lo siguiente:

* **Node.js** y **npm**
* **Git**
* Un editor de código (como **VS Code**)

---

## 🚀 Despliegue del Contrato

Este proyecto está configurado, compilado y desplegado con **Remix**.

### Clonar el Repositorio

```bash
git clone [https://github.com/](https://github.com/)Al3x4nDr0s/kipu-bank.git
cd kipu-bank

## 🤝 Interacción con el Contrato
Una vez que el contrato esté desplegado y verificado, puedes interactuar con él usando tu billetera,  o directamente desde el explorador de bloques (por ejemplo, Etherscan).

1. Depositar ETH
Función: deposit()

Tipo: external payable

Descripción: Envía ETH al contrato. La cantidad de ETH enviada (msg.value) se acredita a tu bóveda personal.

Ejemplo: Envía 0.5 ETH a la dirección del contrato.

2. Retirar ETH
Función: withdraw(uint256 amount)

Tipo: external

Parámetro: amount (la cantidad de wei a retirar)

Descripción: Retira una cantidad específica de ETH de tu bóveda, siempre y cuando no exceda tu saldo ni el transactionWithdrawalCap.

Ejemplo: Llama a withdraw con el valor 500000000000000000 (0.5 ETH).

3. Consultar tu Saldo
Función: getBalance(address user)

Tipo: external view

Parámetro: user (la dirección de la cuenta a consultar)

Descripción: Devuelve el saldo actual de una dirección específica en el banco.

Ejemplo: Llama a getBalance con tu propia dirección.

🌐 Contrato Desplegado y Verificado
El contrato KipuBank ha sido desplegado en la testnet de Sepolia y verificado en su explorador de bloques.

Dirección del Contrato: <Pega-la-dirección-del-contrato-aquí>

Enlace de Verificación: <Pega-el-enlace-a-Etherscan-aquí>

📜 Licencia
Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
