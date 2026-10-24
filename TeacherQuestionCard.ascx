<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherQuestionCard.ascx.cs" Inherits="Codercept.TeacherQuestionCard" %>
<%-- One editable question. Behaviour lives in TeacherPortal.js (data-tp-q-*); field names are (re)assigned there
     as tpq{n}_id / _text / _marks / _type / _a{m} / _correct / _accepted / _model / _guide so the backend can read Request.Form.
     tpq{n}_id is the QuestionId (0 = a new question), so a saved question is recognised even after it was moved. --%>
<article class="question-card" data-tp-question>
    <input type="hidden" data-tp-f="id" value="<%= Question.Id %>" />
    <div class="question-card-header">
        <div>
            <span class="question-number" data-tp-q-number>Q<%= Number %></span>
            <div>
                <small><%= HeaderLabel %></small>
                <strong data-tp-q-title>Question <%= Number %></strong>
            </div>
        </div>
        <div class="question-controls">
            <div class="question-reorder">
                <button type="button" aria-label="Move question up" data-tp-q-up><%= TeacherIcons.Svg("up", 14) %></button>
                <button type="button" aria-label="Move question down" data-tp-q-down><%= TeacherIcons.Svg("down", 14) %></button>
            </div>
            <div class="marks-stepper" data-tp-stepper data-min="1">
                <span>Marks</span>
                <button type="button" aria-label="Decrease marks" data-tp-step="-1">&minus;</button>
                <strong contenteditable="true" role="spinbutton" inputmode="numeric" spellcheck="false" data-tp-step-value aria-label="Marks"><%= Question.Marks %></strong>
                <button type="button" aria-label="Increase marks" data-tp-step="1">+</button>
                <input type="hidden" data-tp-f="marks" data-tp-step-input value="<%= Question.Marks %>" />
            </div>
            <button type="button" class="button button--danger" data-tp-q-delete><%= TeacherIcons.Svg("trash", 17) %><span>Delete</span></button>
        </div>
    </div>

    <label class="form-field question-prompt">
        <span>Question <b>*</b></span>
        <input type="text" data-tp-f="text" value="<%: Question.Text %>" placeholder="Enter your question" />
    </label>

    <% if (HasTypes) { %>
    <div class="question-type-control">
        <span>QUESTION TYPE</span>
        <input type="hidden" data-tp-f="type" data-tp-q-type-value value="<%: Question.Type %>" />
        <div class="segmented-control">
            <button type="button" class="<%= Question.Type == "MCQ" ? "is-active" : "" %>" data-tp-q-type="MCQ">MCQ</button>
            <button type="button" class="<%= Question.Type == "Fill-in-the-blank" ? "is-active" : "" %>" data-tp-q-type="Fill-in-the-blank">Fill-in-the-blank</button>
            <button type="button" class="<%= Question.Type == "Coding" ? "is-active" : "" %>" data-tp-q-type="Coding">Coding</button>
        </div>
    </div>
    <% } %>

    <div class="answer-list" data-tp-q-panel="MCQ"<%= (HasTypes && Question.Type != "MCQ") ? " hidden" : "" %>>
        <span class="answer-list-label">ANSWERS</span>
        <input type="hidden" data-tp-f="correct" value="" />
        <div data-tp-answer-rows data-tp-sortable="[data-tp-answer]" style="display: contents">
            <% for (int i = 0; i < Question.Answers.Count; i++) { %><%= AnswerRow(i, Question.Answers[i].Text, Question.Answers[i].Correct) %><% } %>
        </div>
        <button type="button" class="add-answer-row" data-tp-answer-add><%= TeacherIcons.Svg("plus", 15) %>Add answer</button>
        <template data-tp-answer-template><%= AnswerRow(0, "", false) %></template>
    </div>

    <% if (HasTypes) { %>
    <div class="exam-answer-fields" data-tp-q-panel="Fill-in-the-blank"<%= Question.Type != "Fill-in-the-blank" ? " hidden" : "" %>>
        <label class="form-field">
            <span>Accepted answers <b>*</b></span>
            <input type="text" data-tp-f="accepted" value="<%: Question.AcceptedAnswers %>" placeholder="Separate accepted answers with commas" />
            <small>Add all valid answer variations, separated by commas.</small>
        </label>
    </div>

    <div class="exam-answer-fields" data-tp-q-panel="Coding"<%= Question.Type != "Coding" ? " hidden" : "" %>>
        <label class="form-field">
            <span>Model answer <b>*</b></span>
            <textarea data-tp-f="model" rows="4"><%: Question.ModelAnswer %></textarea>
        </label>
        <label class="form-field">
            <span>Marking guide</span>
            <input type="text" data-tp-f="guide" value="<%: Question.MarkingGuide %>" placeholder="Describe how this answer should be graded" />
        </label>
    </div>
    <% } %>
</article>
