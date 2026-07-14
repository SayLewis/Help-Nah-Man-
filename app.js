const STORAGE_KEY = "help-nah-man-notices-v1";

const initialEvents = [
  {
    id: "notice-1",
    type: "Volunteer",
    title: "Pack 300 food hampers for families across South Trinidad",
    organization: "The Gathering Place",
    cause: "Food support",
    date: offsetDate(3),
    time: "09:00",
    location: "Coffee Street, San Fernando",
    capacity: 40,
    joined: 26,
    contact: "hello@thegatheringplace.tt",
    description: "Help sort pantry items and pack family hampers for distribution. Comfortable shoes and plenty good energy are all you need.",
    postedAt: Date.now() - 1000 * 60 * 60 * 5,
    featured: true,
  },
  {
    id: "notice-2",
    type: "Donation",
    title: "Back-to-school drive needs books, bags and stationery",
    organization: "Bright Futures TT",
    cause: "Education",
    date: offsetDate(6),
    time: "10:00",
    location: "Chaguanas Borough Corporation",
    capacity: 150,
    joined: 82,
    contact: "donate@brightfuturestt.org",
    description: "New and gently used school supplies will support primary school children ahead of the new term. Drop-offs welcome all week.",
    postedAt: Date.now() - 1000 * 60 * 60 * 11,
  },
  {
    id: "notice-3",
    type: "Event",
    title: "Free health checks and family wellness day",
    organization: "Healthy Hearts Caribbean",
    cause: "Health",
    date: offsetDate(8),
    time: "08:00",
    location: "Queen's Park Savannah, Port of Spain",
    capacity: 250,
    joined: 104,
    contact: "868-555-0142",
    description: "Come for blood pressure and glucose screening, talks with local nurses, movement sessions and activities for the whole family.",
    postedAt: Date.now() - 1000 * 60 * 60 * 20,
  },
  {
    id: "notice-4",
    type: "Volunteer",
    title: "Maracas shoreline clean-up and recycling sort",
    organization: "Clean Coast Collective",
    cause: "Environment",
    date: offsetDate(10),
    time: "06:30",
    location: "Maracas Bay",
    capacity: 80,
    joined: 53,
    contact: "join@cleancoast.co.tt",
    description: "Join an early-morning beach clean-up, then help separate and record what we collect. Gloves, bags and water will be provided.",
    postedAt: Date.now() - 1000 * 60 * 60 * 28,
  },
  {
    id: "notice-5",
    type: "Donation",
    title: "Help restock the Arima animal shelter pantry",
    organization: "Paws & Care Network",
    cause: "Animals",
    date: offsetDate(13),
    time: "09:00",
    location: "Calvary Road, Arima",
    capacity: 100,
    joined: 31,
    contact: "pawsandcarett@gmail.com",
    description: "The shelter needs dry food, cleaning supplies and washable blankets. Every contribution keeps rescued animals safe and comfortable.",
    postedAt: Date.now() - 1000 * 60 * 60 * 30,
  },
];

let events = loadEvents();
let activeFilter = "All";
let activeActionId = null;

const elements = {
  todayDate: document.querySelector("#todayDate"),
  totalNotices: document.querySelector("#totalNotices"),
  peopleNeeded: document.querySelector("#peopleNeeded"),
  communitiesCount: document.querySelector("#communitiesCount"),
  leadStory: document.querySelector("#leadStory"),
  eventList: document.querySelector("#eventList"),
  resultCount: document.querySelector("#resultCount"),
  searchInput: document.querySelector("#searchInput"),
  typeFilters: document.querySelector("#typeFilters"),
  sortFilter: document.querySelector("#sortFilter"),
  composerDialog: document.querySelector("#composerDialog"),
  eventForm: document.querySelector("#eventForm"),
  actionDialog: document.querySelector("#actionDialog"),
  actionForm: document.querySelector("#actionForm"),
  actionContent: document.querySelector("#actionContent"),
  newsletterForm: document.querySelector("#newsletterForm"),
  toast: document.querySelector("#toast"),
};

elements.todayDate.textContent = new Intl.DateTimeFormat("en-TT", {
  weekday: "long", month: "long", day: "numeric", year: "numeric",
}).format(new Date());

["#openComposer", "#heroPost", "#asidePost", "#footerPost"].forEach((selector) => {
  document.querySelector(selector).addEventListener("click", openComposer);
});

document.querySelectorAll("[data-nav-filter]").forEach((link) => {
  link.addEventListener("click", () => setFilter(link.dataset.navFilter));
});

elements.searchInput.addEventListener("input", renderFeed);
elements.sortFilter.addEventListener("change", renderFeed);
elements.typeFilters.addEventListener("click", (event) => {
  const button = event.target.closest("[data-filter]");
  if (button) setFilter(button.dataset.filter);
});

elements.eventForm.addEventListener("submit", (event) => {
  if (event.submitter?.value !== "publish") return;
  event.preventDefault();
  const data = new FormData(elements.eventForm);
  const newNotice = {
    id: `notice-${makeId()}`,
    type: data.get("type"),
    title: data.get("title").trim(),
    organization: data.get("organization").trim(),
    cause: data.get("cause"),
    date: data.get("date"),
    time: data.get("time"),
    location: data.get("location").trim(),
    capacity: Number(data.get("capacity")),
    joined: 0,
    contact: data.get("contact").trim(),
    description: data.get("description").trim(),
    postedAt: Date.now(),
  };

  events = [newNotice, ...events];
  saveEvents();
  elements.eventForm.reset();
  elements.composerDialog.close();
  setFilter("All");
  render();
  showToast("Your community notice is now live.");
  document.querySelector("#latest").scrollIntoView({ behavior: "smooth" });
});

elements.actionForm.addEventListener("submit", (event) => {
  if (event.submitter?.value !== "confirm") return;
  event.preventDefault();
  const notice = events.find((item) => item.id === activeActionId);
  if (!notice || openingsFor(notice) < 1) return;
  notice.joined += 1;
  saveEvents();
  elements.actionDialog.close();
  render();
  showToast(actionSuccessMessage(notice.type));
});

elements.newsletterForm.addEventListener("submit", (event) => {
  event.preventDefault();
  elements.newsletterForm.reset();
  showToast("You’re on the list — good news coming your way.");
});

function render() {
  renderStats();
  renderLead();
  renderFeed();
}

function renderStats() {
  elements.totalNotices.textContent = events.length;
  elements.peopleNeeded.textContent = events.reduce((sum, item) => sum + openingsFor(item), 0);
  elements.communitiesCount.textContent = new Set(events.map((item) => item.location.split(",").at(-1).trim())).size;
}

function renderLead() {
  const lead = events.find((item) => item.featured) || [...events].sort((a, b) => dateTimeFor(a) - dateTimeFor(b))[0];
  if (!lead) {
    elements.leadStory.innerHTML = "<h2>The next good thing can start with you.</h2>";
    return;
  }

  elements.leadStory.innerHTML = `
    <span class="lead-badge">Featured need · ${escapeHtml(lead.type)}</span>
    <h2>${escapeHtml(lead.title)}</h2>
    <p>${escapeHtml(lead.description)}</p>
    <div class="lead-meta">
      <span>${formatShortDate(lead.date)}</span>
      <span>•</span>
      <span>${escapeHtml(lead.location)}</span>
      <button class="button button-light" type="button" data-action="${lead.id}">${actionLabel(lead.type)} →</button>
    </div>
  `;
  elements.leadStory.querySelector("[data-action]").addEventListener("click", () => openAction(lead.id));
}

function renderFeed() {
  const filtered = getFilteredEvents();
  elements.resultCount.textContent = `${filtered.length} ${filtered.length === 1 ? "notice" : "notices"}`;

  if (!filtered.length) {
    elements.eventList.innerHTML = `<div class="empty-list"><p><strong>No notices found.</strong><br />Try another search or category.</p></div>`;
    return;
  }

  elements.eventList.innerHTML = filtered.map(storyCard).join("");
  elements.eventList.querySelectorAll("[data-action]").forEach((button) => {
    button.addEventListener("click", () => openAction(button.dataset.action));
  });
  elements.eventList.querySelectorAll("[data-share]").forEach((button) => {
    button.addEventListener("click", () => shareNotice(button.dataset.share));
  });
}

function storyCard(notice) {
  const progress = Math.min(Math.round((notice.joined / notice.capacity) * 100), 100);
  const openings = openingsFor(notice);
  return `
    <article class="story-card">
      <div class="date-block">
        <span>${monthLabel(notice.date)}</span>
        <strong>${dayLabel(notice.date)}</strong>
        <small>${formatTime(notice.time)}</small>
      </div>
      <div class="story-body">
        <div class="story-topline">
          <span class="type-badge ${notice.type.toLowerCase()}">${escapeHtml(notice.type)}</span>
          <span class="cause-label">${escapeHtml(notice.cause)}</span>
        </div>
        <h3><button type="button" data-action="${notice.id}">${escapeHtml(notice.title)}</button></h3>
        <p class="org-line">By ${escapeHtml(notice.organization)}</p>
        <p class="story-description">${escapeHtml(notice.description)}</p>
        <div class="story-meta">
          <span>⌖ ${escapeHtml(notice.location)}</span>
          <span>◷ ${formatLongDate(notice.date)}</span>
        </div>
        <div class="progress-wrap">
          <div class="progress-track" aria-label="${progress}% of support pledged"><span style="width:${progress}%"></span></div>
          <small>${openings} still needed</small>
        </div>
        <div class="story-actions">
          <button class="button button-dark" type="button" data-action="${notice.id}" ${openings === 0 ? "disabled" : ""}>${openings === 0 ? "Goal reached" : actionLabel(notice.type)}</button>
          <button class="share-action" type="button" data-share="${notice.id}">Share notice ↗</button>
        </div>
      </div>
    </article>
  `;
}

function openComposer() {
  const dateInput = elements.eventForm.elements.date;
  dateInput.min = offsetDate(0);
  dateInput.value = dateInput.value || offsetDate(7);
  elements.composerDialog.showModal();
}

function openAction(id) {
  const notice = events.find((item) => item.id === id);
  if (!notice) return;
  activeActionId = id;
  const openings = openingsFor(notice);
  elements.actionContent.className = "action-content";
  elements.actionContent.innerHTML = `
    <span class="type-badge ${notice.type.toLowerCase()}">${escapeHtml(notice.type)}</span>
    <h2>${escapeHtml(notice.title)}</h2>
    <p class="action-org">Organised by ${escapeHtml(notice.organization)}</p>
    <div class="action-detail-grid">
      <div><small>When</small><strong>${formatLongDate(notice.date)}, ${formatTime(notice.time)}</strong></div>
      <div><small>Where</small><strong>${escapeHtml(notice.location)}</strong></div>
    </div>
    <p class="action-copy">${escapeHtml(notice.description)}</p>
    <p class="action-contact"><strong>Next step:</strong> We’ll note your interest here. Please contact <strong>${escapeHtml(notice.contact)}</strong> to confirm the details.</p>
    <button class="button button-coral action-confirm" type="submit" value="confirm" ${openings === 0 ? "disabled" : ""}>${openings === 0 ? "This goal has been reached" : confirmLabel(notice.type)}</button>
  `;
  elements.actionDialog.showModal();
}

function setFilter(filter) {
  activeFilter = filter;
  document.querySelectorAll("[data-filter]").forEach((button) => {
    const active = button.dataset.filter === filter;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", active.toString());
  });
  renderFeed();
}

function getFilteredEvents() {
  const query = elements.searchInput.value.trim().toLowerCase();
  const sort = elements.sortFilter.value;
  return events
    .filter((notice) => {
      const haystack = [notice.title, notice.organization, notice.cause, notice.location, notice.description].join(" ").toLowerCase();
      return (activeFilter === "All" || notice.type === activeFilter) && (!query || haystack.includes(query));
    })
    .sort((a, b) => {
      if (sort === "newest") return b.postedAt - a.postedAt;
      if (sort === "needed") return openingsFor(b) - openingsFor(a);
      return dateTimeFor(a) - dateTimeFor(b);
    });
}

async function shareNotice(id) {
  const notice = events.find((item) => item.id === id);
  if (!notice) return;
  const text = `${notice.title} — ${formatLongDate(notice.date)} at ${notice.location}. Learn more on Help Nah Man. Contact: ${notice.contact}`;
  try {
    if (navigator.share) await navigator.share({ title: notice.title, text });
    else await navigator.clipboard.writeText(text);
    showToast(navigator.share ? "Thanks for spreading the word." : "Notice copied to your clipboard.");
  } catch (error) {
    if (error.name !== "AbortError") showToast("Couldn’t share just now. Please try again.");
  }
}

function actionLabel(type) {
  return type === "Donation" ? "Make a donation" : type === "Event" ? "I want to attend" : "I want to help";
}
function confirmLabel(type) {
  return type === "Donation" ? "Pledge a contribution" : type === "Event" ? "Count me in" : "Volunteer for this";
}
function actionSuccessMessage(type) {
  return type === "Donation" ? "Contribution pledged — thank you for giving." : type === "Event" ? "You’re on the list — see you there." : "Your hand is up — thanks for volunteering.";
}
function openingsFor(notice) { return Math.max(notice.capacity - notice.joined, 0); }
function dateTimeFor(notice) { return new Date(`${notice.date}T${notice.time || "00:00"}`).getTime(); }
function formatShortDate(date) { return new Intl.DateTimeFormat("en-TT", { month: "short", day: "numeric" }).format(new Date(`${date}T12:00:00`)); }
function formatLongDate(date) { return new Intl.DateTimeFormat("en-TT", { weekday: "short", month: "short", day: "numeric" }).format(new Date(`${date}T12:00:00`)); }
function formatTime(time) { return new Intl.DateTimeFormat("en-TT", { hour: "numeric", minute: "2-digit" }).format(new Date(`2026-01-01T${time}`)); }
function monthLabel(date) { return new Intl.DateTimeFormat("en-TT", { month: "short" }).format(new Date(`${date}T12:00:00`)); }
function dayLabel(date) { return new Intl.DateTimeFormat("en-TT", { day: "2-digit" }).format(new Date(`${date}T12:00:00`)); }
function offsetDate(days) { const date = new Date(); date.setDate(date.getDate() + days); return date.toISOString().slice(0, 10); }
function makeId() { return window.crypto?.randomUUID ? window.crypto.randomUUID() : `${Date.now()}-${Math.random().toString(16).slice(2)}`; }
function loadEvents() { try { const saved = JSON.parse(localStorage.getItem(STORAGE_KEY)); if (Array.isArray(saved) && saved.length) return saved; } catch { localStorage.removeItem(STORAGE_KEY); } return initialEvents; }
function saveEvents() { localStorage.setItem(STORAGE_KEY, JSON.stringify(events)); }
function showToast(message) { elements.toast.textContent = message; elements.toast.classList.add("visible"); clearTimeout(showToast.timer); showToast.timer = setTimeout(() => elements.toast.classList.remove("visible"), 2600); }
function escapeHtml(value) { return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#039;"); }

render();
