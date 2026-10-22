/* TeacherPortal.js - vanilla UI behaviour for the Codercept teacher portal.
   Pure UI only (no data access). Everything is wired through data-tp-* attributes so it does not
   depend on ASP.NET-generated IDs. Anything that needs data/persistence is a server control.

   Sections are added batch by batch:
     [core]  drawer, toast, modals
*/
(function () {
    "use strict";

    var TOAST_MS = 2400;
    var toastTimer = null;

    function qs(sel, root) { return (root || document).querySelector(sel); }
    function qsa(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

    /* ------------------------------------------------------------------ [core] toast */
    function toast(message) {
        var el = qs("[data-tp-toast]");
        if (!el) return;
        var text = qs("[data-tp-toast-text]", el);
        if (text) text.textContent = message;
        el.classList.add("is-visible");
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () { el.classList.remove("is-visible"); }, TOAST_MS);
    }

    /* ------------------------------------------------------------------ [core] mobile drawer */
    function setDrawer(open) {
        var sidebar = qs("[data-tp-sidebar]");
        var backdrop = qs("[data-tp-backdrop]");
        if (sidebar) sidebar.classList.toggle("is-open", open);
        if (backdrop) backdrop.classList.toggle("is-visible", open);
    }

    /* ------------------------------------------------------------------ [core] modals */
    var lastTrigger = null;

    function openModal(id) {
        var modal = document.getElementById(id);
        if (!modal) return;
        lastTrigger = document.activeElement;
        modal.hidden = false;
        var focusTarget = qs("[data-tp-autofocus]", modal) || qs("input, button, [href]", modal);
        if (focusTarget) focusTarget.focus();
    }

    function closeModal(modal) {
        if (!modal) return;
        modal.hidden = true;
        if (lastTrigger && lastTrigger.focus) lastTrigger.focus();
    }

    /* ------------------------------------------------------------------ events (delegated) */
    document.addEventListener("click", function (e) {
        var t = e.target;
        if (!(t instanceof Element)) return;

        var open = t.closest("[data-tp-open-menu]");
        if (open) { setDrawer(true); return; }

        if (t.closest("[data-tp-close-menu]")) { setDrawer(false); return; }

        // Navigating from the drawer closes it (the page reloads anyway; this mirrors the prototype)
        if (t.closest("[data-tp-sidebar] .nav-item")) { setDrawer(false); }

        var openModalBtn = t.closest("[data-tp-open-modal]");
        if (openModalBtn) {
            e.preventDefault();
            openModal(openModalBtn.getAttribute("data-tp-open-modal"));
            return;
        }

        var closeModalBtn = t.closest("[data-tp-close-modal]");
        if (closeModalBtn) {
            e.preventDefault();
            closeModal(closeModalBtn.closest("[data-tp-modal]"));
            return;
        }

        var toastBtn = t.closest("[data-tp-toast-msg]");
        if (toastBtn) {
            toast(toastBtn.getAttribute("data-tp-toast-msg"));
            return;
        }

        var printBtn = t.closest("[data-tp-print]");
        if (printBtn) { window.print(); return; }

        var newWin = t.closest("[data-tp-new-window]");
        if (newWin) { window.open(window.location.href, "_blank"); }
    });

    document.addEventListener("keydown", function (e) {
        if (e.key !== "Escape") return;
        var openModalEl = qsa("[data-tp-modal]").filter(function (m) { return !m.hidden; })[0];
        if (openModalEl) { closeModal(openModalEl); return; }
        setDrawer(false);
    });

    // A click on the dimmed backdrop (outside the dialog) closes the modal
    document.addEventListener("mousedown", function (e) {
        var t = e.target;
        if (t instanceof Element && t.hasAttribute("data-tp-modal") && !t.hidden) closeModal(t);
    });

    /* ------------------------------------------------------------------ [selector] */
    function initSelector(root) {
        var pageSize = parseInt(root.getAttribute("data-tp-page-size"), 10) || 3;
        var tiles = qsa("[data-tp-course-tile]", root);
        var grid = qs("[data-tp-sel-grid]", root);
        var empty = qs("[data-tp-sel-empty]", root);
        var popover = qs("[data-tp-sel-filter]", root);
        var filterBtn = qs("[data-tp-sel-filter-toggle]", root);
        var search = qs("[data-tp-sel-search]", root);
        var selLang = qs("[data-tp-sel-lang]", root);
        var selDiff = qs("[data-tp-sel-diff]", root);
        var selDate = qs("[data-tp-sel-date]", root);
        var count = qs("[data-tp-sel-count]", root);
        var stateEl = qs("[data-tp-sel-state]", root);
        var state = { q: "", lang: "All", diff: "All", date: "All", view: "grid", page: 1 };

        try {
            if (stateEl && stateEl.value) {
                var saved = JSON.parse(stateEl.value);
                for (var k in saved) { if (state.hasOwnProperty(k)) state[k] = saved[k]; }
            }
        } catch (err) { /* ignore corrupt state */ }

        search.value = state.q;
        selLang.value = state.lang;
        selDiff.value = state.diff;
        selDate.value = state.date;

        function matches(tile) {
            var idx = parseInt(tile.getAttribute("data-index"), 10);
            if ((tile.getAttribute("data-title") || "").toLowerCase().indexOf(state.q.toLowerCase()) === -1) return false;
            if (state.lang !== "All" && tile.getAttribute("data-language") !== state.lang) return false;
            if (state.diff !== "All" && tile.getAttribute("data-difficulty") !== state.diff) return false;
            if (state.date === "Newest" && !(idx < 3)) return false;
            if (state.date === "Oldest" && !(idx >= 3)) return false;
            return true;
        }

        function render() {
            var filtered = tiles.filter(matches);
            var totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
            var page = Math.min(state.page, totalPages);
            state.page = page;
            var visible = filtered.slice((page - 1) * pageSize, page * pageSize);

            tiles.forEach(function (tile) {
                tile.hidden = visible.indexOf(tile) === -1;
                tile.classList.toggle("is-list", state.view === "list");
            });
            grid.className = "select-course-grid select-course-grid--" + state.view;
            grid.hidden = filtered.length === 0;
            empty.hidden = filtered.length !== 0;
            qsa("[data-tp-sel-view]", root).forEach(function (b) {
                b.classList.toggle("is-active", b.getAttribute("data-tp-sel-view") === state.view);
            });
            count.innerHTML = "<strong>" + page + "</strong> of " + totalPages;
            if (stateEl) stateEl.value = JSON.stringify(state);
            root._tpTotalPages = totalPages;
        }

        search.addEventListener("input", function () { state.q = search.value; render(); });
        // Enter in the search box must not submit the page form
        search.addEventListener("keydown", function (e) { if (e.key === "Enter") e.preventDefault(); });
        selLang.addEventListener("change", function () { state.lang = selLang.value; render(); });
        selDiff.addEventListener("change", function () { state.diff = selDiff.value; render(); });
        selDate.addEventListener("change", function () { state.date = selDate.value; render(); });

        filterBtn.addEventListener("click", function () {
            popover.hidden = !popover.hidden;
            filterBtn.classList.toggle("is-active", !popover.hidden);
        });

        qs("[data-tp-sel-clear]", root).addEventListener("click", function () {
            state.lang = state.diff = state.date = "All";
            selLang.value = selDiff.value = selDate.value = "All";
            render();
        });

        qsa("[data-tp-sel-view]", root).forEach(function (b) {
            b.addEventListener("click", function () { state.view = b.getAttribute("data-tp-sel-view"); render(); });
        });

        qs("[data-tp-sel-prev]", root).addEventListener("click", function () {
            state.page = state.page === 1 ? root._tpTotalPages : state.page - 1;
            render();
        });
        qs("[data-tp-sel-next]", root).addEventListener("click", function () {
            state.page = state.page === root._tpTotalPages ? 1 : state.page + 1;
            render();
        });

        render();
    }

    /* ------------------------------------------------------------------ [courseform] */
    function initCourseForm(root) {
        var title = qs('[data-tp-cf="title"]', root);
        var desc = qs('[data-tp-cf="description"]', root);
        var dur = qs('[data-tp-cf="duration"]', root);
        var lang = qs('[data-tp-cf="language"]', root);
        var diff = qs('[data-tp-cf="difficulty"]', root);
        var langDot = qs("[data-tp-cf-langdot]", root);
        var counter = qs("[data-tp-cf-counter]", root);
        var langMap = {};
        try { langMap = JSON.parse(lang.getAttribute("data-tp-lang-map") || "{}"); } catch (err) { /* ignore */ }
        var tones = { Easy: "success", Medium: "warning", Hard: "danger" };
        // After a server-side validation failure the field already carries .has-error
        var submitted = !!qs(".has-error", root);

        function pv(name) { return qs('[data-tp-pv="' + name + '"]', root); }

        function setField(name, error, success) {
            var field = qs('[data-tp-cf-field="' + name + '"]', root);
            var hint = qs("[data-tp-cf-hint]", field);
            field.classList.toggle("has-error", error);
            field.classList.toggle("has-success", !!success);
            hint.textContent = hint.getAttribute(error ? "data-err" : "data-ok");
        }

        function isValid() {
            var hours = Number(dur.value);
            return title.value.trim().length >= 4 && desc.value.trim().length >= 20 && !!dur.value && hours > 0;
        }

        function update() {
            setField("title", submitted && title.value.trim().length < 4, title.value.length >= 4);
            qs("[data-tp-cf-check]", root).hidden = title.value.length < 4;
            setField("description", submitted && desc.value.trim().length < 20, false);
            setField("duration", submitted && (!dur.value || Number(dur.value) <= 0), false);
            counter.textContent = desc.value.length + "/300";

            var info = langMap[lang.value] || { theme: "python", glyph: "py" };
            langDot.className = "language-dot language-dot--" + info.theme;
            langDot.textContent = info.glyph;
            pv("thumb").className = "course-thumbnail course-thumbnail--" + info.theme + " select-course-thumbnail";
            pv("glyph").textContent = info.glyph;
            pv("title").textContent = title.value || "Your course title";
            pv("title").title = title.value || "Your course title";
            pv("difficulty").textContent = diff.value;
            pv("difficulty").className = "badge badge--" + tones[diff.value];
            pv("duration").textContent = Number(dur.value) || 0;
            qsa("[data-tp-cf-seg]", root).forEach(function (b) {
                b.classList.toggle("is-active", b.getAttribute("data-tp-cf-seg") === diff.value);
            });
        }

        [title, desc, dur].forEach(function (el) { el.addEventListener("input", update); });
        lang.addEventListener("change", update);
        qsa("[data-tp-cf-seg]", root).forEach(function (b) {
            b.addEventListener("click", function () { diff.value = b.getAttribute("data-tp-cf-seg"); update(); });
        });
        qs("[data-tp-cf-clear]", root).addEventListener("click", function () {
            title.value = desc.value = dur.value = "";
            lang.selectedIndex = 0;
            diff.value = "Easy";
            submitted = false;
            update();
        });

        root._tpValidate = function () {
            submitted = true;
            update();
            return isValid();
        };
        update();
    }

    function validateCourseForm() {
        var root = qs("[data-tp-course-form]");
        return root && root._tpValidate ? root._tpValidate() : true;
    }

    /* ------------------------------------------------------------------ [cardlist] search / filter / grid-list / pages over rendered cards */
    function initCardList(root) {
        var pageSize = parseInt(root.getAttribute("data-tp-page-size"), 10) || 3;
        var gridClass = root.getAttribute("data-tp-grid-class");
        var toggleMode = root.hasAttribute("data-tp-cl-toggle");
        var items = qsa("[data-tp-cl-item]", root);
        var grid = qs("[data-tp-cl-grid]", root);
        var empty = qs("[data-tp-cl-empty]", root);
        var popover = qs("[data-tp-cl-filter]", root);
        var filterBtn = qs("[data-tp-cl-filter-toggle]", root);
        var search = qs("[data-tp-cl-search]", root);
        var count = qs("[data-tp-cl-count]", root);
        var gridFlag = root.hasAttribute("data-tp-grid-flag");   // rows use ".is-grid" instead of "--grid/--list"
        var tight = root.hasAttribute("data-tp-count-tight");   // "<strong>1</strong>of 2" without a space
        var state = { q: "", filter: "All", view: root.getAttribute("data-tp-default-view") || "grid", page: 1 };
        var totalPages = 1;

        function render() {
            var filtered = items.filter(function (item) {
                if ((item.getAttribute("data-title") || "").toLowerCase().indexOf(state.q.toLowerCase()) === -1) return false;
                return state.filter === "All" || item.getAttribute("data-status") === state.filter;
            });
            totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
            state.page = Math.min(state.page, totalPages);
            var visible = filtered.slice((state.page - 1) * pageSize, state.page * pageSize);

            items.forEach(function (item) {
                item.hidden = visible.indexOf(item) === -1;
                item.classList.toggle("is-list", state.view === "list");
            });
            grid.className = gridFlag ? gridClass + (state.view === "grid" ? " is-grid" : "") : gridClass + " " + gridClass + "--" + state.view;
            grid.hidden = filtered.length === 0;
            if (empty) empty.hidden = filtered.length !== 0;
            qsa("[data-tp-cl-view]", root).forEach(function (b) {
                b.classList.toggle("is-active", b.getAttribute("data-tp-cl-view") === state.view);
            });
            qsa("[data-tp-cl-opt]", root).forEach(function (o) {
                var on = o.getAttribute("data-tp-cl-opt") === state.filter;
                o.classList.toggle("is-active", on);
                var check = qs("[data-tp-cl-check]", o);
                if (check) check.hidden = !on;
            });
            count.innerHTML = "<strong>" + state.page + "</strong>" + (tight ? "of " : " of ") + totalPages;
        }

        search.addEventListener("input", function () { state.q = search.value; render(); });
        search.addEventListener("keydown", function (e) { if (e.key === "Enter") e.preventDefault(); });

        if (filterBtn && popover) {
            filterBtn.addEventListener("click", function () {
                popover.hidden = !popover.hidden;
                filterBtn.classList.toggle("is-active", !popover.hidden);
            });
        }

        qsa("[data-tp-cl-opt]", root).forEach(function (o) {
            o.addEventListener("click", function () {
                var value = o.getAttribute("data-tp-cl-opt");
                state.filter = (toggleMode && state.filter === value) ? "All" : value;
                state.page = 1;
                render();
            });
        });
        var clearBtn = qs("[data-tp-cl-clear]", root);
        if (clearBtn) clearBtn.addEventListener("click", function () { state.filter = "All"; render(); });

        qsa("[data-tp-cl-view]", root).forEach(function (b) {
            b.addEventListener("click", function () { state.view = b.getAttribute("data-tp-cl-view"); render(); });
        });
        qs("[data-tp-cl-prev]", root).addEventListener("click", function () {
            state.page = state.page === 1 ? totalPages : state.page - 1;
            render();
        });
        qs("[data-tp-cl-next]", root).addEventListener("click", function () {
            state.page = state.page === totalPages ? 1 : state.page + 1;
            render();
        });
        render();
    }

    /* ------------------------------------------------------------------ [stepper] + [toggle] */
    function changed(el) { el.dispatchEvent(new CustomEvent("tp-change", { bubbles: true })); }

    document.addEventListener("click", function (e) {
        var t = e.target;
        if (!(t instanceof Element)) return;

        var step = t.closest("[data-tp-step]");
        if (step) {
            var root = step.closest("[data-tp-stepper]");
            var min = root.hasAttribute("data-min") ? parseInt(root.getAttribute("data-min"), 10) : -Infinity;
            var max = root.hasAttribute("data-max") ? parseInt(root.getAttribute("data-max"), 10) : Infinity;
            var input = qs("[data-tp-step-input]", root);
            var value = Math.min(max, Math.max(min, (parseInt(input.value, 10) || 0) + parseInt(step.getAttribute("data-tp-step"), 10)));
            input.value = value;
            qs("[data-tp-step-value]", root).textContent = value;
            changed(root);
            return;
        }

        var toggle = t.closest("[data-tp-toggle]");
        if (toggle) {
            var on = !toggle.classList.contains("is-on");
            toggle.classList.toggle("is-on", on);
            toggle.setAttribute("aria-pressed", on ? "true" : "false");
            var hidden = qs("[data-tp-toggle-input]", toggle.parentNode);
            if (hidden) hidden.value = on ? "1" : "0";
            changed(toggle);
        }
    });

    /* ------------------------------------------------------------------ [questions] question cards (exam / quiz / assessment) */
    function initQuestions(container) {
        var template = qs("template[data-tp-q-template]", container);
        var addBtn = qs("[data-tp-q-anchor]", container) || qs("[data-tp-q-add]", container);

        function cards() { return qsa("[data-tp-question]", container); }

        function setNames(card, n) {
            qsa("[data-tp-f]", card).forEach(function (el) {
                var f = el.getAttribute("data-tp-f");
                if (f === "answer" || f === "correct") return;
                el.name = "tpq" + n + "_" + f;
            });
            var rows = qsa("[data-tp-answer]", card);
            rows.forEach(function (row, m) {
                qs('[data-tp-f="answer"]', row).name = "tpq" + n + "_a" + m;
                qs("[data-tp-answer-remove]", row).setAttribute("aria-label", "Remove answer " + (m + 1));
                qs('[data-tp-f="answer"]', row).setAttribute("aria-label", "Answer " + (m + 1));
                qs(".answer-letter", row).textContent = String.fromCharCode(65 + m);
            });
            var correct = qs('[data-tp-f="correct"]', card);
            if (correct) {
                var idx = -1;
                rows.forEach(function (row, m) { if (row.classList.contains("is-correct")) idx = m; });
                correct.name = "tpq" + n + "_correct";
                correct.value = idx;
            }
        }

        function updateTotals() {
            var list = cards();
            var total = 0;
            list.forEach(function (card) { total += parseInt(qs('[data-tp-f="marks"]', card).value, 10) || 0; });
            var totalEl = qs("[data-tp-total-marks]");
            var countEl = qs("[data-tp-total-count]");
            if (totalEl) totalEl.textContent = total;
            if (countEl) countEl.textContent = "Across " + list.length + (list.length === 1 ? " question" : " questions");
        }

        function renumber() {
            cards().forEach(function (card, i) {
                qs("[data-tp-q-number]", card).textContent = "Q" + (i + 1);
                qs("[data-tp-q-title]", card).textContent = "Question " + (i + 1);
                setNames(card, i + 1);
            });
            updateTotals();
        }

        // Make the move visible: scroll the moved card into view and briefly highlight it
        function flashMoved(card) {
            card.scrollIntoView({ block: "nearest", behavior: "smooth" });
            card.classList.remove("tp-moved");
            void card.offsetWidth;
            card.classList.add("tp-moved");
            window.setTimeout(function () { card.classList.remove("tp-moved"); }, 1200);
        }

        function setCorrect(card, row) {
            qsa("[data-tp-answer]", card).forEach(function (r) {
                var on = r === row;
                r.classList.toggle("is-correct", on);
                qs(".correct-label", r).hidden = !on;
                qs("[data-tp-answer-correct]", r).hidden = on;
            });
            renumber();
        }

        function showType(card, type) {
            qs("[data-tp-q-type-value]", card).value = type;
            qsa("[data-tp-q-type]", card).forEach(function (b) { b.classList.toggle("is-active", b.getAttribute("data-tp-q-type") === type); });
            qsa("[data-tp-q-panel]", card).forEach(function (p) { p.hidden = p.getAttribute("data-tp-q-panel") !== type; });
        }

        container.addEventListener("click", function (e) {
            var t = e.target;
            if (!(t instanceof Element)) return;
            var card = t.closest("[data-tp-question]");

            if (t.closest("[data-tp-q-add]")) {
                if (!template) return;
                var fresh = template.content.firstElementChild.cloneNode(true);
                container.insertBefore(fresh, addBtn);
                renumber();
                return;
            }
            if (!card) return;

            if (t.closest("[data-tp-q-delete]")) { card.remove(); renumber(); return; }

            var up = t.closest("[data-tp-q-up]");
            var down = t.closest("[data-tp-q-down]");
            if (up && card.previousElementSibling && card.previousElementSibling.hasAttribute("data-tp-question")) {
                container.insertBefore(card, card.previousElementSibling);
                renumber();
                flashMoved(card);
                return;
            }
            if (down && card.nextElementSibling && card.nextElementSibling.hasAttribute("data-tp-question")) {
                container.insertBefore(card.nextElementSibling, card);
                renumber();
                flashMoved(card);
                return;
            }

            var type = t.closest("[data-tp-q-type]");
            if (type) { showType(card, type.getAttribute("data-tp-q-type")); return; }

            var correct = t.closest("[data-tp-answer-correct]");
            if (correct) { setCorrect(card, correct.closest("[data-tp-answer]")); return; }

            var remove = t.closest("[data-tp-answer-remove]");
            if (remove) {
                var row = remove.closest("[data-tp-answer]");
                row.remove();
                renumber();
                return;
            }

            if (t.closest("[data-tp-answer-add]")) {
                var tpl = qs("template[data-tp-answer-template]", card);
                qs("[data-tp-answer-rows]", card).appendChild(tpl.content.firstElementChild.cloneNode(true));
                renumber();
            }
        });

        container.addEventListener("tp-change", updateTotals);
        container.addEventListener("tp-reorder", renumber);
        // Pressing Enter in a question field must not submit the page
        container.addEventListener("keydown", function (e) {
            if (e.key === "Enter" && e.target instanceof HTMLInputElement) e.preventDefault();
        });
        renumber();
    }

    /* ------------------------------------------------------------------ [sortable] drag the grip handle to reorder
       A container opts in with data-tp-sortable="<css selector of its draggable items>". After a drop it raises "tp-reorder". */
    (function () {
        var dragged = null;

        function itemFromHandle(handle) {
            var el = handle.parentElement;
            while (el && el !== document.body) {
                var parent = el.parentElement;
                if (parent && parent.hasAttribute("data-tp-sortable") && el.matches(parent.getAttribute("data-tp-sortable"))) return el;
                el = parent;
            }
            return null;
        }

        // The item is only draggable while the grip is pressed, so text inside inputs stays selectable
        document.addEventListener("mousedown", function (e) {
            var handle = e.target instanceof Element ? e.target.closest(".drag-handle") : null;
            var item = handle ? itemFromHandle(handle) : null;
            if (item) item.draggable = true;
        });
        document.addEventListener("mouseup", function () {
            qsa("[draggable=true]").forEach(function (el) { if (!dragged) el.draggable = false; });
        });

        document.addEventListener("dragstart", function (e) {
            var el = e.target instanceof Element ? e.target : null;
            var parent = el ? el.parentElement : null;
            if (!el || !parent || !parent.hasAttribute("data-tp-sortable") || !el.matches(parent.getAttribute("data-tp-sortable"))) return;
            dragged = el;
            e.dataTransfer.effectAllowed = "move";
            try { e.dataTransfer.setData("text/plain", "tp-reorder"); } catch (err) { /* old browsers */ }
            window.setTimeout(function () { if (dragged) dragged.classList.add("tp-dragging"); }, 0);
        });

        document.addEventListener("dragover", function (e) {
            if (!dragged) return;
            e.preventDefault();
            var container = dragged.parentElement;
            var selector = container.getAttribute("data-tp-sortable");
            var siblings = Array.prototype.filter.call(container.children, function (c) { return c !== dragged && c.matches(selector); });
            var before = null;
            for (var i = 0; i < siblings.length; i++) {
                var rect = siblings[i].getBoundingClientRect();
                if (e.clientY < rect.top + rect.height / 2) { before = siblings[i]; break; }
            }
            if (before) {
                if (dragged.nextElementSibling !== before) container.insertBefore(dragged, before);
            } else if (siblings.length) {
                var last = siblings[siblings.length - 1];
                if (last.nextElementSibling !== dragged) container.insertBefore(dragged, last.nextElementSibling);
            }
        });

        document.addEventListener("drop", function (e) { if (dragged) e.preventDefault(); });

        document.addEventListener("dragend", function () {
            if (!dragged) return;
            var container = dragged.parentElement;
            dragged.classList.remove("tp-dragging");
            dragged.draggable = false;
            dragged = null;
            container.dispatchEvent(new CustomEvent("tp-reorder", { bubbles: true }));
        });
    })();

    /* ------------------------------------------------------------------ [chapters] chapter list: pick (posts the page) + up/down order */
    function initChapterList(list) {
        var picked = qs("[data-tp-chapter-input]");
        var orderInput = qs("[data-tp-chapter-order]");

        function items() { return qsa("[data-tp-chapter-pick]", list); }

        function refresh() {
            var all = items();
            all.forEach(function (item, i) {
                qs("[data-tp-ch-up]", item).disabled = i === 0;
                qs("[data-tp-ch-down]", item).disabled = i === all.length - 1;
            });
            if (orderInput) orderInput.value = all.map(function (item) { return item.getAttribute("data-tp-chapter-pick"); }).join(",");
        }

        function pick(item) {
            picked.value = item.getAttribute("data-tp-chapter-pick");
            refresh();
            document.forms[0].submit();
        }

        list.addEventListener("click", function (e) {
            var t = e.target;
            if (!(t instanceof Element)) return;
            var item = t.closest("[data-tp-chapter-pick]");
            if (!item) return;
            var up = t.closest("[data-tp-ch-up]");
            var down = t.closest("[data-tp-ch-down]");
            if (up || down) {
                // moving a chapter only reorders the list; it does not select it
                if (up && item.previousElementSibling) list.insertBefore(item, item.previousElementSibling);
                if (down && item.nextElementSibling) list.insertBefore(item.nextElementSibling, item);
                refresh();
                return;
            }
            pick(item);
        });
        list.addEventListener("tp-reorder", refresh);
        list.addEventListener("keydown", function (e) {
            var item = e.target instanceof Element ? e.target.closest("[data-tp-chapter-pick]") : null;
            if (item && e.target === item && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); pick(item); }
        });
        refresh();
    }

    /* ------------------------------------------------------------------ [content list] highlight only (as in the prototype) */
    function initContentList(list) {
        var orderInput = qs("[data-tp-content-order]");

        function renumber() {
            var items = qsa("[data-tp-content-item]", list);
            items.forEach(function (item, i) {
                var label = qs("small", item);
                label.textContent = (item.getAttribute("data-type") === "quiz" ? "QUIZ " : "SUBCHAPTER ") + (i + 1);
            });
            if (orderInput) orderInput.value = items.map(function (item) { return item.getAttribute("data-id"); }).join(",");
        }

        list.addEventListener("tp-reorder", renumber);
        list.addEventListener("click", function (e) {
            var item = e.target instanceof Element ? e.target.closest("[data-tp-content-item]") : null;
            if (!item) return;
            qsa("[data-tp-content-item]", list).forEach(function (b) { b.classList.toggle("is-active", b === item); });
        });
    }

    /* ------------------------------------------------------------------ [dropzone] click or drop a file */
    function initDropzone(zone) {
        var btn = qs("[data-tp-dropzone-btn]", zone);
        var input = qs("[data-tp-dropzone-input]", zone);
        var title = qs("[data-tp-dropzone-title]", zone);
        var original = title.textContent;

        function show() { title.textContent = input.files && input.files.length ? input.files[0].name : original; }

        btn.addEventListener("click", function () { input.click(); });
        input.addEventListener("change", show);
        ["dragenter", "dragover"].forEach(function (name) {
            btn.addEventListener(name, function (e) { e.preventDefault(); btn.classList.add("is-active"); });
        });
        btn.addEventListener("dragleave", function () { btn.classList.remove("is-active"); });
        btn.addEventListener("drop", function (e) {
            e.preventDefault();
            btn.classList.remove("is-active");
            if (e.dataTransfer && e.dataTransfer.files.length) { input.files = e.dataTransfer.files; show(); }
        });
    }

    /* ------------------------------------------------------------------ [grading] pick assessment + learner, live total */
    function initGrading(root) {
        var tiles = qsa("[data-tp-assessment]", root);
        var assessmentInput = qs("[data-tp-grade-assessment]", root);
        var learnerInput = qs("[data-tp-grade-learner]", root);
        var trigger = qs("[data-tp-submission-trigger]", root);
        var menu = qs("[data-tp-submission-menu]", root);
        var options = qsa("[data-tp-submission]", root);
        var statusClass = { "Graded": "is-graded", "In progress": "is-progress", "Not graded": "is-ungraded" };
        var assessment = { title: "", questions: "", pending: 0 };

        function esc(text) {
            var d = document.createElement("div");
            d.textContent = text;
            return d.innerHTML;
        }

        function current() {
            return options[parseInt(learnerInput.value, 10)] || options[0];
        }

        function render() {
            var opt = current();
            var name = opt.getAttribute("data-name");
            var submitted = opt.getAttribute("data-submitted");
            var avatar = '<span class="avatar avatar--' + opt.getAttribute("data-tone") + ' avatar--sm" aria-hidden="true">' + esc(opt.getAttribute("data-initials")) + "</span>";
            var status = opt.getAttribute("data-status");

            trigger.innerHTML = avatar + "<span><strong>" + esc(name) + "</strong><small>Submitted " + esc(submitted) + "</small></span>"
                + '<span class="submission-status ' + statusClass[status] + '">' + esc(status) + "</span>"
                + qs("[data-tp-down-icon]", root).innerHTML;

            options.forEach(function (o) {
                var on = o === opt;
                o.classList.toggle("is-selected", on);
                qs("[data-tp-submission-check]", o).hidden = !on;
            });

            var panelAvatar = qs("[data-tp-panel-avatar]", root);
            panelAvatar.className = "avatar avatar--" + opt.getAttribute("data-tone") + " avatar--sm";
            panelAvatar.textContent = opt.getAttribute("data-initials");
            qs("[data-tp-panel-name]", root).textContent = name;
            qs("[data-tp-panel-submitted]", root).textContent = "Submitted " + submitted;
            qs("[data-tp-grade-subtitle]", root).textContent = "Reviewing " + name + "'s answers for " + assessment.title + ".";
            var confirmName = qs("[data-tp-confirm-learner]");
            if (confirmName) confirmName.textContent = name;
        }

        function selectTile(tile) {
            assessment = {
                title: tile.getAttribute("data-title"),
                questions: tile.getAttribute("data-questions"),
                pending: parseInt(tile.getAttribute("data-pending"), 10)
            };
            assessmentInput.value = assessment.title;
            tiles.forEach(function (t) {
                var on = t === tile;
                t.classList.toggle("is-selected", on);
                qs("[data-tp-tile-check]", t).hidden = !on;
            });
            qs("[data-tp-sum-title]", root).textContent = assessment.title;
            qs("[data-tp-sum-text]", root).innerHTML = assessment.questions + " questions &middot; 100 total marks";
            var badge = qs("[data-tp-sum-badge]", root);
            badge.textContent = assessment.pending + " pending";
            badge.className = "badge badge--" + (assessment.pending ? "warning" : "success");
            qs("[data-tp-grade-qcount]", root).textContent = assessment.questions;
            render();
        }

        function updateTotal() {
            var total = 0;
            qsa("[data-tp-grade-marks]", root).forEach(function (input) { total += parseInt(input.value, 10) || 0; });
            qs("[data-tp-grade-total]", root).textContent = total + " / 100";
            qs("[data-tp-grade-bar]", root).style.width = Math.min(100, total) + "%";
            var confirmTotal = qs("[data-tp-confirm-total]");
            if (confirmTotal) confirmTotal.textContent = total + " / 100";
        }

        tiles.forEach(function (tile) { tile.addEventListener("click", function () { selectTile(tile); }); });

        trigger.addEventListener("click", function () {
            menu.hidden = !menu.hidden;
            trigger.setAttribute("aria-expanded", menu.hidden ? "false" : "true");
        });
        options.forEach(function (o, i) {
            o.addEventListener("click", function () {
                learnerInput.value = i;
                menu.hidden = true;
                trigger.setAttribute("aria-expanded", "false");
                render();
            });
        });

        root.addEventListener("tp-change", updateTotal);
        // The confirm dialog is outside this root; refresh it just before it opens
        document.addEventListener("click", function (e) {
            if (e.target instanceof Element && e.target.closest('[data-tp-open-modal="tpConfirmGradeModal"]')) { updateTotal(); render(); }
        }, true);

        selectTile(tiles.filter(function (t) { return t.getAttribute("data-title") === assessmentInput.value; })[0] || tiles[0]);
        updateTotal();
    }

    /* ------------------------------------------------------------------ [edit fields] language dot + segmented control (edit forms) */
    function initEditFields() {
        qsa("[data-tp-langselect]").forEach(function (select) {
            var dot = qs("[data-tp-langdot]", select.closest(".language-select"));
            var map = {};
            try { map = JSON.parse(select.getAttribute("data-tp-lang-map") || "{}"); } catch (err) { /* ignore */ }
            function sync() {
                var info = map[select.value];
                if (!info || !dot) return;
                dot.className = "language-dot language-dot--" + info.theme;
                dot.textContent = info.glyph;
            }
            select.addEventListener("change", sync);
            sync();
        });

        qsa("[data-tp-seg-group]").forEach(function (group) {
            var value = qs("[data-tp-seg-value]", group);
            var buttons = qsa("[data-tp-seg]", group);
            function sync() {
                buttons.forEach(function (b) { b.classList.toggle("is-active", b.getAttribute("data-tp-seg") === value.value); });
            }
            buttons.forEach(function (b) {
                b.addEventListener("click", function () { value.value = b.getAttribute("data-tp-seg"); sync(); });
            });
            sync();
        });
    }

    /* ------------------------------------------------------------------ [learners] search filter */
    function initLearnerSearch() {
        qsa("[data-tp-learner-search]").forEach(function (input) {
            var items = qsa("[data-tp-learner-item]");
            input.addEventListener("input", function () {
                var q = input.value.toLowerCase();
                items.forEach(function (item) { item.hidden = (item.getAttribute("data-search") || "").indexOf(q) === -1; });
            });
            // Enter must not submit the page form (it would "click" the first learner)
            input.addEventListener("keydown", function (e) { if (e.key === "Enter") e.preventDefault(); });
        });
    }

    /* ------------------------------------------------------------------ [report] zoom 80 / 100 / 120 */
    function initZoom(root) {
        var levels = [80, 100, 120];
        var index = 1;
        var wrap = qs("[data-tp-zoom-wrap]", root);
        var label = qs("[data-tp-zoom-label]", root);
        var out = qs("[data-tp-zoom-out]", root);
        var inn = qs("[data-tp-zoom-in]", root);

        function render() {
            wrap.className = "report-paper-wrap zoom-" + levels[index];
            label.textContent = levels[index] + "%";
            out.disabled = index === 0;
            inn.disabled = index === levels.length - 1;
        }
        out.addEventListener("click", function () { index = Math.max(0, index - 1); render(); });
        inn.addEventListener("click", function () { index = Math.min(levels.length - 1, index + 1); render(); });
        render();
    }

    /* ------------------------------------------------------------------ [forum] */
    function initForum(root) {
        var selected = qs("[data-tp-forum-selected]", root);
        var mobile = qs("[data-tp-forum-mobile]", root);
        var replying = qs("[data-tp-forum-replying]", root);
        var replyingLabel = qs("[data-tp-forum-replying-label]", root);
        var replyInput = qs("[data-tp-forum-reply-input]", root);
        var title = qs("[data-tp-forum-title]", root);

        function closeFlags() { qsa("[data-tp-forum-flag-pop]", root).forEach(function (p) { p.hidden = true; }); }

        function select(id, openOnMobile) {
            qsa("[data-tp-forum-post]", root).forEach(function (card) {
                var on = card.getAttribute("data-tp-forum-post") === id;
                card.classList.toggle("is-selected", on);
                if (on) title.textContent = card.getAttribute("data-title");
            });
            qsa("[data-tp-forum-thread]", root).forEach(function (t) { t.hidden = t.getAttribute("data-tp-forum-thread") !== id; });
            selected.value = id;
            closeFlags();
            setReplying("");
            if (openOnMobile) { root.classList.add("show-discussion"); mobile.value = "1"; }
        }

        function setReplying(name) {
            replying.value = name;
            replyingLabel.hidden = !name;
            replyingLabel.textContent = name ? "Replying to " + name : "";
        }

        root.addEventListener("click", function (e) {
            var t = e.target;
            if (!(t instanceof Element)) return;

            var card = t.closest("[data-tp-forum-post]");
            if (card) { select(card.getAttribute("data-tp-forum-post"), true); return; }

            if (t.closest("[data-tp-forum-back]")) { root.classList.remove("show-discussion"); mobile.value = "0"; return; }

            var reply = t.closest("[data-tp-forum-reply]");
            if (reply) { setReplying(reply.getAttribute("data-tp-forum-reply")); replyInput.focus(); return; }

            var flag = t.closest("[data-tp-forum-flag]");
            if (flag) {
                var pop = qs("[data-tp-forum-flag-pop]", flag.closest(".comment-popover-wrap"));
                var wasOpen = !pop.hidden;
                closeFlags();
                pop.hidden = wasOpen;
                return;
            }
            if (t.closest("[data-tp-forum-flag-cancel]")) closeFlags();
        });

        // Enter in the reply box sends the reply instead of triggering whichever submit button comes first
        replyInput.addEventListener("keydown", function (e) {
            if (e.key !== "Enter") return;
            e.preventDefault();
            qs("[data-tp-forum-send]", root).click();
        });
    }

    /* ------------------------------------------------------------------ [forum] new post tag preview */
    function initTagPreview(source) {
        var preview = qs("[data-tp-tag-preview]");
        if (!preview) return;
        function render() {
            preview.innerHTML = "";
            source.value.split(",").forEach(function (raw) {
                var tag = raw.trim().replace(/^#/, "").trim();
                if (!tag) return;
                var chip = document.createElement("span");
                chip.className = "tag-chip is-preview";
                chip.textContent = "#" + tag;
                preview.appendChild(chip);
            });
        }
        source.addEventListener("input", render);
        render();
    }

    /* ------------------------------------------------------------------ [account] delete confirmation */
    function initDeleteAccount(input) {
        var modal = input.closest("[data-tp-modal]");
        var confirmBtn = qs(".button--danger", modal);
        var email = input.getAttribute("data-tp-delete-email");
        function sync() {
            var ok = input.value === email;
            confirmBtn.setAttribute("aria-disabled", ok ? "false" : "true");
        }
        input.addEventListener("input", sync);
        confirmBtn.addEventListener("click", function (e) {
            if (confirmBtn.getAttribute("aria-disabled") === "true") { e.preventDefault(); e.stopImmediatePropagation(); }
        }, true);
        sync();
    }

    function init() {
        initEditFields();
        initLearnerSearch();
        qsa("[data-tp-cardlist]").forEach(initCardList);
        qsa("[data-tp-questions]").forEach(initQuestions);
        qsa("[data-tp-chapter-list]").forEach(initChapterList);
        qsa("[data-tp-content-list]").forEach(initContentList);
        qsa("[data-tp-dropzone]").forEach(initDropzone);
        qsa("[data-tp-grading]").forEach(initGrading);
        qsa("[data-tp-forum]").forEach(initForum);
        qsa("[data-tp-tag-source]").forEach(initTagPreview);
        qsa("[data-tp-delete-email]").forEach(initDeleteAccount);
        qsa("[data-tp-zoom]").forEach(initZoom);
        qsa("[data-tp-selector]").forEach(initSelector);
        qsa("[data-tp-course-form]").forEach(initCourseForm);
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
    else init();

    window.TeacherPortal = { toast: toast, openModal: openModal, closeModal: closeModal, setDrawer: setDrawer, validateCourseForm: validateCourseForm };
})();
