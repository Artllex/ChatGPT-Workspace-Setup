"use strict";

const HOST = "com.artllex.download_router";
const api = typeof browser !== "undefined" ? browser : {
  i18n: { getUILanguage: () => navigator.language },
  storage: { local: { get: async defaults => defaults, set: async () => {} } },
  runtime: { sendNativeMessage: async () => { throw new Error("Native host unavailable"); } }
};
const translations = {
pl: {
  subtitle: "Zapisuj pliki z wybranych portali dokładnie tam, gdzie chcesz.",
  languageLabel: "Język",
  languageAuto: "Automatycznie (Firefox)",
  chatgptTitle: "Wbudowana reguła rozmów",
  chatgptDescription: "Pliki z ChatGPT trafiają do folderu TEMP ustawionego przez ChatGPT Workspace Setup, w podfolderze o nazwie rozmowy.",
  routesTitle: "Pozostałe portale",
  routesDescription: "Dodaj domenę i folder docelowy. Reguła obejmie również jej subdomeny.",
  diagnosticsTitle: "Stan rozszerzenia",
  versionLabel: "Wersja",
  activityLabel: "Ostatnia aktywność",
  activityNone: "brak",
  activity_context: "wykryto kliknięcie",
  activity_matched: "dopasowano regułę",
  activity_unmatched: "brak pasującej reguły",
  activity_moved: "plik przeniesiony",
  activity_error: "błąd",
  addRoute: "+ Dodaj portal",
  emptyState: "Nie dodano jeszcze żadnych portali.",
  domain: "Portal / domena",
  folder: "Folder docelowy",
  browse: "Wybierz…",
  remove: "Usuń regułę",
  save: "Zapisz ustawienia",
  saved: "Ustawienia zapisane.",
  invalid: "Uzupełnij poprawną domenę i pełną ścieżkę folderu dla każdej pozycji.",
  hostError: "Najpierw zainstaluj ChatGPT Workspace Setup 1.2.3, aby wybierać foldery."
},
en: {
  subtitle: "Save files from selected websites exactly where you want them.",
  languageLabel: "Language",
  languageAuto: "Automatic (Firefox)",
  chatgptTitle: "Built-in conversation rule",
  chatgptDescription: "ChatGPT files go to the TEMP folder configured by ChatGPT Workspace Setup, inside a subfolder named after the conversation.",
  routesTitle: "Other websites",
  routesDescription: "Add a domain and destination folder. Its subdomains are included automatically.",
  diagnosticsTitle: "Extension status",
  versionLabel: "Version",
  activityLabel: "Last activity",
  activityNone: "none",
  activity_context: "click detected",
  activity_matched: "route matched",
  activity_unmatched: "no matching route",
  activity_moved: "file moved",
  activity_error: "error",
  addRoute: "+ Add website",
  emptyState: "No website routes have been added yet.",
  domain: "Website / domain",
  folder: "Destination folder",
  browse: "Browse…",
  remove: "Remove route",
  save: "Save settings",
  saved: "Settings saved.",
  invalid: "Enter a valid domain and a full folder path for every route.",
  hostError: "Install ChatGPT Workspace Setup 1.2.3 before choosing folders."
}
};

let text = translations.en;

const routesElement = document.querySelector("#routes");
const emptyElement = document.querySelector("#emptyState");
const statusElement = document.querySelector("#status");

function applyText() {
  for (const id of ["subtitle", "languageLabel", "chatgptTitle", "chatgptDescription", "routesTitle", "routesDescription", "diagnosticsTitle", "versionLabel", "activityLabel", "addRoute", "emptyState", "save"]) {
    document.querySelector("#" + id).textContent = text[id];
  }
  document.querySelector('#language option[value="auto"]').textContent = text.languageAuto;
  for (const row of routesElement.querySelectorAll(".route")) {
    row.querySelector(".domainLabel").textContent = text.domain;
    row.querySelector(".folderLabel").textContent = text.folder;
    row.querySelector(".browse").textContent = text.browse;
    row.querySelector(".remove").setAttribute("aria-label", text.remove);
    row.querySelector(".remove").title = text.remove;
  }
  renderActivity();
}

let currentActivity = null;

function renderActivity() {
  const activity = currentActivity;
  document.querySelector("#lastActivity").textContent = activity ? (text["activity_" + activity.stage] || activity.stage) : text.activityNone;
  document.querySelector("#activityDetails").textContent = activity && activity.details ? activity.details : "";
}

function firefoxLanguage() {
  const locale = api.i18n && api.i18n.getUILanguage ? api.i18n.getUILanguage() : navigator.language;
  return locale.toLowerCase().startsWith("pl") ? "pl" : "en";
}

function selectTranslation(value) {
  text = translations[value === "auto" ? firefoxLanguage() : value] || translations.en;
  applyText();
  statusElement.textContent = "";
}

function normalizeDomain(value) {
  const input = value.trim().toLowerCase();
  if (!input) return "";
  try {
    const url = new URL(input.includes("://") ? input : "https://" + input);
    return url.hostname.replace(/^www\./, "");
  } catch (_) {
    return "";
  }
}

function refreshEmptyState() {
  emptyElement.hidden = routesElement.children.length > 0;
}

function addRoute(route = {}) {
  const row = document.querySelector("#routeTemplate").content.firstElementChild.cloneNode(true);
  row.querySelector(".domainLabel").textContent = text.domain;
  row.querySelector(".folderLabel").textContent = text.folder;
  row.querySelector(".domain").value = route.domain || "";
  row.querySelector(".folder").value = route.folder || "";
  const browse = row.querySelector(".browse");
  browse.textContent = text.browse;
  browse.addEventListener("click", async () => {
    statusElement.textContent = "";
    try {
      const response = await api.runtime.sendNativeMessage(HOST, {
        action: "chooseFolder",
        initialFolder: row.querySelector(".folder").value
      });
      if (response.ok && response.folder) row.querySelector(".folder").value = response.folder;
    } catch (_) {
      statusElement.textContent = text.hostError;
    }
  });
  const remove = row.querySelector(".remove");
  remove.setAttribute("aria-label", text.remove);
  remove.title = text.remove;
  remove.addEventListener("click", () => { row.remove(); refreshEmptyState(); });
  routesElement.append(row);
  refreshEmptyState();
}

async function save() {
  const routes = [...routesElement.querySelectorAll(".route")].map(row => ({
    domain: normalizeDomain(row.querySelector(".domain").value),
    folder: row.querySelector(".folder").value.trim().replace(/[\\/]+$/, "")
  }));
  const valid = routes.every(route => route.domain && /^[a-z]:\\/i.test(route.folder));
  if (!valid) {
    statusElement.textContent = text.invalid;
    return;
  }
  await api.storage.local.set({ routes, language: document.querySelector("#language").value });
  statusElement.textContent = text.saved;
}

async function restore() {
  const settings = await api.storage.local.get({ routes: [], language: "auto", lastActivity: null });
  currentActivity = settings.lastActivity;
  document.querySelector("#extensionVersion").textContent = api.runtime.getManifest ? api.runtime.getManifest().version : "preview";
  document.querySelector("#language").value = settings.language;
  selectTranslation(settings.language);
  settings.routes.forEach(addRoute);
  refreshEmptyState();
}

document.querySelector("#addRoute").addEventListener("click", () => addRoute());
document.querySelector("#save").addEventListener("click", save);
document.querySelector("#language").addEventListener("change", event => selectTranslation(event.target.value));
if (api.storage.onChanged) api.storage.onChanged.addListener(changes => {
  if (changes.lastActivity) { currentActivity = changes.lastActivity.newValue; renderActivity(); }
});
restore();
