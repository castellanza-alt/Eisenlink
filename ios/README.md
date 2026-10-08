# Eisenlink helper — app iOS nativa

SwiftUI + SceneKit, iOS 18+, solo iPhone/portrait, nessuna dipendenza, nessuna rete.
Il riferimento di comportamento è la web app nella radice del repo (`index.html`).

- Progetto generato da XcodeGen (`ios/project.yml`); Team ID `5E426PLFWN`, bundle ID `it.castellanza.eisenlink`.
- Firma automatica con chiave API App Store Connect (nessun certificato nel repo).
- Workflow: `iOS — verifica` (test unitari su simulatore) e `iOS — Carica su TestFlight` (manuale, tag `ios-v*` oppure modifica di `ios/RELEASE` sul ramo).

## Segreti del repo (Settings → Secrets and variables → Actions)

Chiave API **propria di Eisenlink**, ruolo Admin (o App Manager), creata in App Store Connect → Users and Access → Integrations → Team Keys.

| Nome | Contenuto |
|---|---|
| `ASC_KEY_ID` | Key ID della chiave |
| `ASC_ISSUER_ID` | Issuer ID |
| `ASC_PRIVATE_KEY` | contenuto del `.p8` (testo intero, oppure base64) |

Prima del primo upload serve il record app in App Store Connect: nome «Eisenlink helper», bundle ID `it.castellanza.eisenlink`, lingua italiano, SKU `eisenlink-helper`.

Mai committare `.p8`, token o password.
