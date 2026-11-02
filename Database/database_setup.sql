USE [Codercept_db];
GO

-- ==========================================
-- 1. DROP ALL TABLES (Reverse Dependency Order)
-- ==========================================
DROP TABLE IF EXISTS [dbo].[LearnerProgress];
DROP TABLE IF EXISTS [dbo].[User_Log];
DROP TABLE IF EXISTS [dbo].[Qualification];
DROP TABLE IF EXISTS [dbo].[ForumRead];
DROP TABLE IF EXISTS [dbo].[Post_Reply];
DROP TABLE IF EXISTS [dbo].[Teacher_AiUsage];
DROP TABLE IF EXISTS [dbo].[Moderate_Forum];
DROP TABLE IF EXISTS [dbo].[Forum];
DROP TABLE IF EXISTS [dbo].[EducatorSubject];
DROP TABLE IF EXISTS [dbo].[TeacherSubject];
DROP TABLE IF EXISTS [dbo].[EducatorSubject];
DROP TABLE IF EXISTS [dbo].[CourseSubject];
DROP TABLE IF EXISTS [dbo].[Course_Review];
DROP TABLE IF EXISTS [dbo].[Certificate];
DROP TABLE IF EXISTS [dbo].[GradingProgress];
DROP TABLE IF EXISTS [dbo].[Result];
DROP TABLE IF EXISTS [dbo].[AttemptAnswer];
DROP TABLE IF EXISTS [dbo].[Attempt];
DROP TABLE IF EXISTS [dbo].[MCQ_Option];
DROP TABLE IF EXISTS [dbo].[Question];
DROP TABLE IF EXISTS [dbo].[Quiz];
DROP TABLE IF EXISTS [dbo].[Exam];
DROP TABLE IF EXISTS [dbo].[Assessment];
DROP TABLE IF EXISTS [dbo].[SubChapter];
DROP TABLE IF EXISTS [dbo].[Chapter];
DROP TABLE IF EXISTS [dbo].[Course];
DROP TABLE IF EXISTS [dbo].[Teaching_Assistant];
DROP TABLE IF EXISTS [dbo].[Teacher];
DROP TABLE IF EXISTS [dbo].[Learner];
DROP TABLE IF EXISTS [dbo].[Subject];
DROP TABLE IF EXISTS [dbo].[Application];
DROP TABLE IF EXISTS [dbo].[Admin];
DROP TABLE IF EXISTS [dbo].[Notification];

-- ==========================================
-- 2. CREATE ALL TABLES (Forward Dependency Order)
-- ==========================================

CREATE TABLE [dbo].[Notification] (
    [NotificationId] INT            IDENTITY (1, 1) NOT NULL,
    [Title]          NVARCHAR (255) NOT NULL,
    [Content]        NVARCHAR (MAX) NOT NULL,
    [Type]           NVARCHAR (50)  NOT NULL,
    [DateTime]       DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([NotificationId] ASC)
);

CREATE TABLE [dbo].[Admin] (
    [AdminId]   INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (50)  NOT NULL,
    [Email]     NVARCHAR (50)  NOT NULL,
    [Password]  NVARCHAR (255) NOT NULL,
    [Role]      NVARCHAR (50)  NOT NULL,
    [AccStatus] NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    PRIMARY KEY CLUSTERED ([AdminId] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC)
);

CREATE TABLE [dbo].[Application] (
    [ApplicationId]         INT            IDENTITY (1, 1) NOT NULL,
    [RoleApplied]           NVARCHAR (50)  NOT NULL,
    [QualificationName]     NVARCHAR (50)  NULL,
    [CredentialDocument]    NVARCHAR (MAX) NULL,
    [ApprovalStatus]        NVARCHAR (50)  NOT NULL DEFAULT 'Pending',
    [RejectReason]          NVARCHAR (MAX) NULL,
    [DateSubmitted]         DATETIME       NOT NULL DEFAULT GETDATE(),
    [DateReviewed]          DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ApplicationId] ASC),
    CONSTRAINT [CK_Application_Role] CHECK ([RoleApplied] IN ('Teacher', 'Teaching Assistant')),
    CONSTRAINT [CK_Application_Status] CHECK ([ApprovalStatus] IN ('Pending', 'Approved', 'Rejected'))
);

CREATE TABLE [dbo].[Subject] (
    [SubjectId]   INT           IDENTITY (1, 1) NOT NULL,
    [SubjectName] NVARCHAR (50) NOT NULL,
    [SubjectType] NVARCHAR (20) NOT NULL DEFAULT 'Domain',
    PRIMARY KEY CLUSTERED ([SubjectId] ASC),
    UNIQUE NONCLUSTERED ([SubjectName] ASC),
    CONSTRAINT [CK_Subject_SubjectType] CHECK ([SubjectType] IN ('Language', 'Domain'))
);

CREATE TABLE [dbo].[Learner] (
    [LearnerId]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (50)  NOT NULL,
    [Email]      NVARCHAR (50)  NOT NULL,
    [Password]   NVARCHAR (255) NOT NULL,
    [DateJoined] DATETIME       NOT NULL DEFAULT GETDATE(),
    [AccStatus]  NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    [Age]        INT            NULL,
    [Address]    NVARCHAR (MAX) NULL,
    [Occupation] NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([LearnerId] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC)
);

CREATE TABLE [dbo].[Teacher] (
    [TeacherId]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50)  NOT NULL,
    [Email]         NVARCHAR (50)  NOT NULL,
    [Password]      NVARCHAR (255) NOT NULL,
    [Age]           INT            NULL,
    [Region]        NVARCHAR (50)  NULL,
    [TeachingLevel] NVARCHAR (50)  NULL,
    [QualificationName] NVARCHAR (50)  NULL,
    [QualificationDocument] NVARCHAR (MAX) NULL,
    [AccStatus]     NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    [DateJoined]    DATETIME       NOT NULL DEFAULT GETDATE(),
    [ApplicationId] INT            NULL,
    PRIMARY KEY CLUSTERED ([TeacherId] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC),
    CONSTRAINT [FK_Teacher_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
);

CREATE TABLE [dbo].[Teaching_Assistant] (
    [TA_Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [Name]                  NVARCHAR (50)  NOT NULL,
    [Email]                 NVARCHAR (50)  NOT NULL,
    [Password]              NVARCHAR (255) NOT NULL,
    [Age]                   INT            NULL,
    [Region]                NVARCHAR (50)  NULL,
    [TeachingLevel]         NVARCHAR (50)  NULL,
    [QualificationName]     NVARCHAR (50)  NULL,
    [QualificationDocument] NVARCHAR (MAX) NULL,
    [AccStatus]             NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    [DateJoined]            DATETIME       NOT NULL DEFAULT GETDATE(),
    [ApplicationId]         INT            NULL,
    PRIMARY KEY CLUSTERED ([TA_Id] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC),
    CONSTRAINT [FK_TeachingAssistant_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
);

CREATE TABLE [dbo].[Course] (
    [CourseId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]      DATETIME       NOT NULL,
    [DateUpdate]        DATETIME       NULL,
    [CourseTitle]       NVARCHAR (255) NOT NULL,
    [CourseDescription] NVARCHAR (MAX) NOT NULL,
    [DifficultyLevel]   NVARCHAR (50)  NOT NULL,
    [CourseDuration]    NVARCHAR (50)  NOT NULL,
    [TeacherId]         INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([CourseId] ASC),
    CONSTRAINT [FK_Course_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Chapter] (
    [ChapterId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]       DATETIME       NOT NULL,
    [DateUpdate]         DATETIME       NULL,
    [ChapterNum]         FLOAT (53)     NOT NULL,
    [ChapterTitle]       NVARCHAR (50)  NOT NULL,
    [ChapterDescription] NVARCHAR (MAX) NOT NULL,
    [ChapterDuration]    NVARCHAR (50)  NOT NULL,
    [ChapterMediaLink]   NVARCHAR (MAX) NULL,
    [CourseId]           INT            NOT NULL,
    [TeacherId]          INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ChapterId] ASC),
    CONSTRAINT [FK_Chapter_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_Chapter_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[SubChapter] (
    [SubChapterId]        INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]        DATETIME       NOT NULL,
    [DateUpdate]          DATETIME       NOT NULL,
    [SubChapterOrder]     FLOAT (53)     NOT NULL,
    [SubChapterTitle]     NVARCHAR (50)  NOT NULL,
    [SubChapterContent]   NVARCHAR (MAX) NOT NULL,
    [SubChapterMediaLink] NVARCHAR (MAX) NULL,
    [SubChapterDuration]  INT            NOT NULL, -- minutes
    [ChapterId]           INT            NOT NULL,
    [TeacherId]           INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([SubChapterId] ASC),
    CONSTRAINT [CK_SubChapter_Duration] CHECK ([SubChapterDuration] > 0),
    CONSTRAINT [FK_SubChapter_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_SubChapter_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Assessment] (
    [AssessmentId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]          DATETIME       NOT NULL,
    [DateUpdate]            DATETIME       NOT NULL,
    [AssessmentTitle]       NVARCHAR (50)  NOT NULL,
    [AssessmentDescription] NVARCHAR (MAX) NOT NULL,
    [AssessmentMediaLink]   NVARCHAR (MAX) NULL,
    [ChapterId]             INT            NOT NULL,
    [TeacherId]             INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([AssessmentId] ASC),
    UNIQUE NONCLUSTERED ([ChapterId] ASC), -- at most one assessment per chapter (and not together with a quiz: checked in the teacher pages)
    CONSTRAINT [FK_Assessment_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_Assessment_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Exam] (
    [ExamId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]    DATETIME       NOT NULL,
    [DateUpdate]      DATETIME       NULL,
    [ExamTitle]       NVARCHAR (50)  NOT NULL,
    [ExamDescription] NVARCHAR (MAX) NOT NULL,
    [PassMark]        INT            NOT NULL,
    [TimeLimitMinutes] INT           NOT NULL,
    [StrictSyntax]    BIT            NOT NULL, -- rule: the learner's code must follow the language syntax strictly
    [AllowLibraries]  BIT            NOT NULL, -- rule: the learner may use libraries
    [CourseId]        INT            NOT NULL,
    [TeacherId]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ExamId] ASC),
    CONSTRAINT [CK_Exam_PassMark] CHECK ([PassMark] BETWEEN 0 AND 100),
    CONSTRAINT [CK_Exam_TimeLimit] CHECK ([TimeLimitMinutes] BETWEEN 5 AND 300),
    UNIQUE NONCLUSTERED ([CourseId] ASC), -- one final exam per course; learners take it to earn the certificate
    CONSTRAINT [FK_Exam_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_Exam_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Quiz] (
    [QuizId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]    DATETIME       NOT NULL,
    [DateUpdate]      DATETIME       NOT NULL,
    [QuizTitle]       NVARCHAR (50)  NOT NULL,
    [QuizDescription] NVARCHAR (MAX) NOT NULL,
    [QuizMediaLink]   NVARCHAR (MAX) NULL,
    [ChapterId]       INT            NOT NULL,
    [TeacherId]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([QuizId] ASC),
    UNIQUE NONCLUSTERED ([ChapterId] ASC), -- at most one quiz per chapter (and not together with an assessment: checked in the teacher pages)
    CONSTRAINT [FK_Quiz_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_Quiz_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Question] (
    [QuestionId]      INT            IDENTITY (1, 1) NOT NULL,
    [QuestionContent] NVARCHAR (MAX) NOT NULL,
    [QuestionType]    NVARCHAR (50)  NOT NULL,
    [QuestionScore]   FLOAT (53)     NOT NULL,
    [QuestionOrder]   INT            NOT NULL,
    [AcceptedAnswers] NVARCHAR (MAX) NULL, -- fill-in-the-blank: the accepted answers, comma-separated
    [ModelAnswer]     NVARCHAR (MAX) NULL, -- coding: the teacher's model answer
    [MarkingGuide]    NVARCHAR (MAX) NULL, -- coding: how the marks are given
    [TeacherId]       INT            NOT NULL,
    [QuizId]          INT            NULL,
    [AssessmentId]    INT            NULL,
    [ExamId]          INT            NULL,
    PRIMARY KEY CLUSTERED ([QuestionId] ASC),
    CONSTRAINT [CK_Question_Type] CHECK ([QuestionType] IN ('MCQ', 'FillBlank', 'Coding')),
    CONSTRAINT [CK_Question_OneOwner] CHECK ((CASE WHEN [QuizId] IS NULL THEN 0 ELSE 1 END)
        + (CASE WHEN [AssessmentId] IS NULL THEN 0 ELSE 1 END) + (CASE WHEN [ExamId] IS NULL THEN 0 ELSE 1 END) = 1),
    CONSTRAINT [FK_Question_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_Question_Quiz] FOREIGN KEY ([QuizId]) REFERENCES [dbo].[Quiz] ([QuizId]),
    CONSTRAINT [FK_Question_Assessment] FOREIGN KEY ([AssessmentId]) REFERENCES [dbo].[Assessment] ([AssessmentId]),
    CONSTRAINT [FK_Question_Exam] FOREIGN KEY ([ExamId]) REFERENCES [dbo].[Exam] ([ExamId])
);

CREATE TABLE [dbo].[MCQ_Option] (
    [MCQ_OptionId]  INT            IDENTITY (1, 1) NOT NULL,
    [OptionContent] NVARCHAR (MAX) NOT NULL,
    [IsCorrect]     BIT            NOT NULL,
    [OptionOrder]   INT            NOT NULL,
    [QuestionId]    INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([MCQ_OptionId] ASC),
    CONSTRAINT [FK_MCQOption_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId])
);

CREATE TABLE [dbo].[Attempt] (
    [AttemptId]     INT           IDENTITY (1, 1) NOT NULL,
    [AttemptDate]   DATETIME      NOT NULL,
    [AttemptStatus] NVARCHAR (50) NOT NULL,
    [LearnerId]     INT           NOT NULL,
    [QuizId]        INT           NULL,
    [AssessmentId]  INT           NULL,
    [ExamId]        INT           NULL,
    PRIMARY KEY CLUSTERED ([AttemptId] ASC),
    CONSTRAINT [FK_Attempt_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_Attempt_Quiz] FOREIGN KEY ([QuizId]) REFERENCES [dbo].[Quiz] ([QuizId]),
    CONSTRAINT [FK_Attempt_Assessment] FOREIGN KEY ([AssessmentId]) REFERENCES [dbo].[Assessment] ([AssessmentId]),
    CONSTRAINT [FK_Attempt_Exam] FOREIGN KEY ([ExamId]) REFERENCES [dbo].[Exam] ([ExamId])
);

CREATE TABLE [dbo].[AttemptAnswer] (
    [AttemptId]      INT            NOT NULL,
    [QuestionId]     INT            NOT NULL,
    [AnswerContent]  NVARCHAR (MAX) NOT NULL,
    [IsCorrect]      NVARCHAR (50)  NOT NULL,
    [ObtainedScore]  FLOAT (53)     NOT NULL,
    [TeacherComment] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_AttemptAnswer] PRIMARY KEY CLUSTERED ([AttemptId] ASC, [QuestionId] ASC),
    CONSTRAINT [FK_AttemptAnswer_Attempt] FOREIGN KEY ([AttemptId]) REFERENCES [dbo].[Attempt] ([AttemptId]),
    CONSTRAINT [FK_AttemptAnswer_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId])
);

CREATE TABLE [dbo].[Result] (
    [ResultId]       INT            IDENTITY (1, 1) NOT NULL,
    [TotalScore]     FLOAT (53)     NOT NULL,
    [Grade]          NVARCHAR (50)  NOT NULL,
    [Average]        FLOAT (53)     NOT NULL,
    [ResultFeedback] NVARCHAR (MAX) NOT NULL,
    [AttemptId]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ResultId] ASC),
    CONSTRAINT [FK_Result_Attempt] FOREIGN KEY ([AttemptId]) REFERENCES [dbo].[Attempt] ([AttemptId])
);

CREATE TABLE [dbo].[GradingProgress] (
    [GradingProgId]  INT            IDENTITY (1, 1) NOT NULL,
    [ProgressStatus] NVARCHAR (50)  NOT NULL,
    [ProgressNotes]  NVARCHAR (MAX) NOT NULL,
    [TeacherId]      INT            NULL,
    [TA_Id]          INT            NULL,
    [AttemptId]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([GradingProgId] ASC),
    CONSTRAINT [FK_GradingProgress_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_GradingProgress_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id]),
    CONSTRAINT [FK_GradingProgress_Attempt] FOREIGN KEY ([AttemptId]) REFERENCES [dbo].[Attempt] ([AttemptId])
);

CREATE TABLE [dbo].[Certificate] (
    [CertId]    INT           IDENTITY (1, 1) NOT NULL,
    [Issuer]    NVARCHAR (50) NOT NULL,
    [IssueDate] DATETIME      NOT NULL,
    [LearnerId] INT           NOT NULL,
    [CourseId]  INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([CertId] ASC),
    CONSTRAINT [FK_Certificate_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_Certificate_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId])
);

CREATE TABLE [dbo].[Course_Review] (
    [ReviewId]       INT            IDENTITY (1, 1) NOT NULL,
    [CourseFeedBack] NVARCHAR (MAX) NOT NULL,
    [Rating]         FLOAT (53)     NOT NULL,
    [SubmissionDate] DATETIME       NOT NULL,
    [CourseId]       INT            NOT NULL,
    [LearnerId]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ReviewId] ASC),
    CONSTRAINT [FK_CourseReview_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_CourseReview_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId])
);

CREATE TABLE [dbo].[CourseSubject] (
    [CourseId]  INT NOT NULL,
    [SubjectId] INT NOT NULL,
    CONSTRAINT [PK_CourseSubject] PRIMARY KEY CLUSTERED ([CourseId] ASC, [SubjectId] ASC),
    CONSTRAINT [FK_CourseSubject_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId]),
    CONSTRAINT [FK_CourseSubject_Subject] FOREIGN KEY ([SubjectId]) REFERENCES [dbo].[Subject] ([SubjectId])
);

CREATE TABLE [dbo].[EducatorSubject] (
    [EducatorSubjectId] INT IDENTITY (1, 1) NOT NULL,
    [TeacherId]         INT NULL,
    [TA_Id]             INT NULL,
    [SubjectId]         INT NOT NULL,
    CONSTRAINT [PK_EducatorSubject] PRIMARY KEY CLUSTERED ([EducatorSubjectId] ASC),
    CONSTRAINT [FK_EducatorSubject_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_EducatorSubject_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id]),
    CONSTRAINT [FK_EducatorSubject_Subject] FOREIGN KEY ([SubjectId]) REFERENCES [dbo].[Subject] ([SubjectId]),
    CONSTRAINT [CK_EducatorSubject_Owner] CHECK (([TeacherId] IS NOT NULL AND [TA_Id] IS NULL) OR ([TeacherId] IS NULL AND [TA_Id] IS NOT NULL))
);

CREATE UNIQUE NONCLUSTERED INDEX [UX_EducatorSubject_Teacher] ON [dbo].[EducatorSubject] ([TeacherId], [SubjectId]) WHERE [TeacherId] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX [UX_EducatorSubject_TA] ON [dbo].[EducatorSubject] ([TA_Id], [SubjectId]) WHERE [TA_Id] IS NOT NULL;

CREATE TABLE [dbo].[Forum] (
    [PostId]     INT            IDENTITY (1, 1) NOT NULL,
    [Title]      NVARCHAR (255) NOT NULL,
    [Content]    NVARCHAR (MAX) NOT NULL,
    [DatePosted] DATETIME       NOT NULL,
    [LearnerId]  INT            NULL,
    [Tags]       NVARCHAR (255) NULL, -- comma-separated, for example 'Python,Fundamental'
    [TeacherId]  INT            NULL,
    [IsFlagged]  BIT            NOT NULL DEFAULT 0, -- moderation: shown with a red background
    [IsHidden]   BIT            NOT NULL DEFAULT 0, -- moderation: not shown on the forum page (the row is kept)
    PRIMARY KEY CLUSTERED ([PostId] ASC),
    CONSTRAINT [CK_Forum_OneAuthor] CHECK ((CASE WHEN [LearnerId] IS NULL THEN 0 ELSE 1 END) + (CASE WHEN [TeacherId] IS NULL THEN 0 ELSE 1 END) = 1), -- written by a learner or by a teacher
    CONSTRAINT [FK_Forum_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_Forum_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Moderate_Forum] (
    [ModerateId]     INT            IDENTITY (1, 1) NOT NULL,
    [PostId]         INT            NOT NULL,
    [TeacherId]      INT            NULL,
    [TA_Id]          INT            NULL,
    [ModerateAction] NVARCHAR (20)  NOT NULL, -- 'Flag', 'Hide', 'Delete'
    [ModerateReason] NVARCHAR (MAX) NOT NULL,
    [DateModerate]   DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_ModerateForum] PRIMARY KEY CLUSTERED ([ModerateId] ASC),
    CONSTRAINT [CK_ModerateForum_Action] CHECK ([ModerateAction] IN ('Flag', 'Hide', 'Delete')),
    CONSTRAINT [CK_ModerateForum_OneModerator] CHECK ((CASE WHEN [TeacherId] IS NULL THEN 0 ELSE 1 END) + (CASE WHEN [TA_Id] IS NULL THEN 0 ELSE 1 END) = 1), -- done by a teacher or by a teaching assistant
    CONSTRAINT [FK_ModerateForum_Forum] FOREIGN KEY ([PostId]) REFERENCES [dbo].[Forum] ([PostId]),
    CONSTRAINT [FK_ModerateForum_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_ModerateForum_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

-- One row for every call the teacher AI assistant sends to Groq (who, which feature, how it ended, tokens, time). Never the text of a question or an answer.
CREATE TABLE [dbo].[Teacher_AiUsage] (
    [UsageId]     INT           IDENTITY (1, 1) NOT NULL,
    [TeacherId]   INT           NOT NULL,
    [Feature]     NVARCHAR (10) NOT NULL, -- 'course', 'chapter' or 'chat'
    [Outcome]     NVARCHAR (20) NOT NULL, -- 'ok' or the name of the error
    [TotalTokens] INT           NULL,
    [DurationMs]  INT           NOT NULL,
    [DateUsed]    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_TeacherAiUsage] PRIMARY KEY CLUSTERED ([UsageId] ASC),
    CONSTRAINT [CK_TeacherAiUsage_Feature] CHECK ([Feature] IN ('course', 'chapter', 'chat')),
    CONSTRAINT [FK_TeacherAiUsage_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Post_Reply] (
    [ThreadId]     INT            IDENTITY (1, 1) NOT NULL,
    [DatePinned]   DATETIME       NULL,
    [ReplyComment] NVARCHAR (MAX) NOT NULL,
    [IsPinned]     NVARCHAR (50)  NOT NULL,
    [DateReplied]  DATETIME       NOT NULL DEFAULT GETDATE(),
    [PostId]       INT            NOT NULL,
    [LearnerId]    INT            NULL,
    [TeacherId]    INT            NULL,
    [TA_Id]        INT            NULL,
    [ParentThreadId] INT          NULL, -- the reply this one answers (NULL = a reply to the post itself)
    PRIMARY KEY CLUSTERED ([ThreadId] ASC),
    CONSTRAINT [FK_PostReply_Parent] FOREIGN KEY ([ParentThreadId]) REFERENCES [dbo].[Post_Reply] ([ThreadId]),
    CONSTRAINT [FK_PostReply_Forum] FOREIGN KEY ([PostId]) REFERENCES [dbo].[Forum] ([PostId]),
    CONSTRAINT [FK_PostReply_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_PostReply_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_PostReply_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

CREATE TABLE [dbo].[ForumRead] (
    [PostId]   INT      NOT NULL,
    [TeacherId] INT     NOT NULL,
    [DateRead] DATETIME NOT NULL, -- the teacher has seen this post (it no longer counts as unread)
    CONSTRAINT [PK_ForumRead] PRIMARY KEY CLUSTERED ([PostId] ASC, [TeacherId] ASC),
    CONSTRAINT [FK_ForumRead_Forum] FOREIGN KEY ([PostId]) REFERENCES [dbo].[Forum] ([PostId]),
    CONSTRAINT [FK_ForumRead_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[User_Log] (
    [LogId]         INT      IDENTITY (1, 1) NOT NULL,
    [StartDateTime] DATETIME NOT NULL,
    [EndDateTime]   DATETIME NULL,
    [LearnerId]     INT      NULL,
    [TeacherId]     INT      NULL,
    [TA_Id]         INT      NULL,
    [AdminId]       INT      NULL,
    PRIMARY KEY CLUSTERED ([LogId] ASC),
    CONSTRAINT [FK_UserLog_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_UserLog_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_UserLog_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id]),
    CONSTRAINT [FK_UserLog_Admin] FOREIGN KEY ([AdminId]) REFERENCES [dbo].[Admin] ([AdminId])
);

CREATE TABLE [dbo].[LearnerProgress] (
    [LearnerId] INT NOT NULL,
    [CourseId]  INT NOT NULL,
    [ChapNum]   INT NULL,
    [EnrolledDate] DATETIME NOT NULL DEFAULT GETDATE(), -- when the learner joined the course
    CONSTRAINT [PK_LearnerCourse] PRIMARY KEY CLUSTERED ([LearnerId] ASC, [CourseId] ASC),
    CONSTRAINT [FK_LearnerCourse_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_LearnerCourse_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId])
);

-- ==========================================
-- 3. INSERT MOCK DATA
-- ==========================================

-- Insert Platform Announcements / Notifications
INSERT INTO [dbo].[Notification] ([Title], [Content], [Type], [DateTime])
VALUES 
    ('New C++ Module Now Available!', 'We are excited to announce the launch of "Data Structures with C++" by Prof. Michael Torres. Enroll today to master linked lists, trees, and hash tables from scratch.', 'Announcement', DATEADD(DAY, -2, GETDATE())),
    ('Python Hackathon 2026 Invitation', 'Join us for the CodeLearn National Python Marathon this coming weekend! You will collaborate in teams to solve competitive programming tasks, optimize neuroevolution models, and earn official platform badges and certificates.', 'Invitation', DATEADD(HOUR, -6, GETDATE()));

-- Insert SuperAdmin Account
INSERT INTO [dbo].[Admin] ([Name], [Email], [Password], [Role])
VALUES ('Tang Chee Kin', 'tterry616@gmail.com', '$2a$12$L0eoOITSHTUuJNtBrjDnB.D8yZ.usDG7ZhmUhXh14lG6K6uff.7y2', 'SuperAdmin');

-- Insert Learner Account
INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES ('Kylan Shane Sedrick', 'ttck0413@gmail.com', '$2a$12$cNIkYdVSLG5nagfnR3fD4.zdnNIpAj7GHgY7a1qC2LmOPUt73mbs2', GETDATE(), 'Active', 21, 'Negeri Sembilan, Malaysia', 'Student');
INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES ('Wan Hon Kit', 'wan1234@gmail.com', '$2a$12$UtK5EgXtoXPquMKIIrcTuufwaCSlhcz6o6xpWX3zcWuDag3j5yJoO', GETDATE(), 'Active', 21, 'Penang, Malaysia', 'Student');


-- ==========================================
-- Teacher portal test data (Backend Phase 1, Step 1.1)
-- Two teachers, so ownership can be tested: Teacher A must never see or change Teacher B's data.
-- Rows are linked by unique values (Email, SubjectName) or SCOPE_IDENTITY(), so no identity numbers are hard-coded.
-- ==========================================

-- Teachers (passwords are BCrypt cost-12 hashes, same format as the Admin and Learner rows)
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Bryan Yeong', 'bryanyeong@edu.com.my', '$2a$12$CKfrdV0bSGGst.bMr8A4G.RmmIaI93SA9kx3hrkvmk.V/PulB/SwK', 32, 'Kuala Lumpur, Malaysia', 'Advanced', 'Active', '2026-01-15', NULL);
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Sarah Lim', 'sarahlim@edu.com.my', '$2a$12$ctWavkUvhh0JdPtUx8H1A.s/tF.pNnBRb8qDhxQDSMnrjrZSw6taW', 29, 'Penang, Malaysia', 'Intermediate', 'Active', '2026-03-10', NULL);
-- Newly registered teacher with no courses yet (for testing empty states). Password: Newbie1234!
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Nina Tan', 'ninatan@edu.com.my', '$2a$12$.Jve0o18RkIO0nDUO2dgN.Q5o7WUW8GLGlq5s/i2fobHTY1RNZpTu', 26, 'Johor Bahru, Malaysia', 'Beginner', 'Active', '2026-10-20', NULL);

-- Subjects: the four programming languages taught on the platform, plus learning domains
INSERT INTO [dbo].[Subject] ([SubjectName], [SubjectType])
VALUES
    ('Python', 'Language'),
    ('Java', 'Language'),
    ('C++', 'Language'),
    ('C', 'Language'),
    ('Machine Learning', 'Domain'),
    ('Data Analysis', 'Domain');

DECLARE @BryanId INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'bryanyeong@edu.com.my');
DECLARE @SarahId INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'sarahlim@edu.com.my');
DECLARE @CourseId INT;

-- Course: Python Programming Fundamentals (Bryan Yeong)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -28, GETDATE()), 'Python Programming Fundamentals', 'Build a strong foundation in Python through practical examples, clear explanations, and hands-on programming exercises.', 'Easy', '18 hours', @BryanId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Python'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 1, 'Introduction to Python', 'Get set up with Python, run your first program, and learn how Python code is structured.', '2 hours', N'media/uploads/1/chapter-01-introduction-to-python.jpg', @CourseId, @BryanId),
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -33, GETDATE()), 2, 'Variables and Data Types', 'Understand variables, strings, numbers, booleans, and common type conversions in Python.', '3 hours', N'media/uploads/1/chapter-02-variables-and-data-types.png', @CourseId, @BryanId),
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -30, GETDATE()), 3, 'Control Flow', 'Make decisions and repeat work with if statements, for loops, and while loops.', '4 hours', N'media/uploads/1/chapter-03-control-flow.jpg', @CourseId, @BryanId);

-- Course: Java Programming Masterclass (Bryan Yeong)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -30, GETDATE()), 'Java Programming Masterclass', 'Master object-oriented Java, from core syntax and collections to robust application architecture and testing.', 'Hard', '32 hours', @BryanId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Java'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -50, GETDATE()), 1, 'Java Basics and Syntax', 'Learn the structure of a Java program, primitive types, operators, and basic input and output.', '3 hours', N'media/uploads/2/chapter-01-java-basics-and-syntax.jpg', @CourseId, @BryanId),
    (DATEADD(DAY, -52, GETDATE()), DATEADD(DAY, -45, GETDATE()), 2, 'Object-Oriented Programming', 'Model real problems with classes, objects, inheritance, interfaces, and polymorphism.', '5 hours', N'media/uploads/2/chapter-02-object-oriented-programming.png', @CourseId, @BryanId);

-- Course: Data Analysis with Python (Bryan Yeong)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -70, GETDATE()), DATEADD(DAY, -45, GETDATE()), 'Data Analysis with Python', 'Clean, explore, and visualise real datasets using Python, pandas, and charts that tell a clear story.', 'Medium', '24 hours', @BryanId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Python'));
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Data Analysis'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -70, GETDATE()), DATEADD(DAY, -65, GETDATE()), 1, 'Working with Data in Python', 'Load data from files and inspect it with lists, dictionaries, and pandas DataFrames.', '3 hours', N'media/uploads/3/chapter-01-working-with-data-in-python.jpg', @CourseId, @BryanId),
    (DATEADD(DAY, -68, GETDATE()), DATEADD(DAY, -60, GETDATE()), 2, 'Cleaning and Transforming Data', 'Handle missing values, fix types, filter rows, and reshape data ready for analysis.', '4 hours', N'media/uploads/3/chapter-02-cleaning-and-transforming-data.png', @CourseId, @BryanId),
    (DATEADD(DAY, -66, GETDATE()), DATEADD(DAY, -58, GETDATE()), 3, 'Visualising Results', 'Turn data into clear charts and summaries that answer a question.', '3.5 hours', N'media/uploads/3/chapter-03-visualising-results.jpg', @CourseId, @BryanId);

-- Course: C Programming Essentials (Sarah Lim)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -12, GETDATE()), 'C Programming Essentials', 'Learn the fundamentals of C, from variables and control flow to functions, arrays, and pointers.', 'Easy', '20 hours', @SarahId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -20, GETDATE()), 1, 'Introduction to C', 'Get familiar with the C language, its tools, and the structure of a first program.', '2 hours', N'media/uploads/4/chapter-01-introduction-to-c.jpg', @CourseId, @SarahId),
    (DATEADD(DAY, -23, GETDATE()), DATEADD(DAY, -18, GETDATE()), 2, 'Variables and Data Types', 'Understand variables, constants, primitive data types, and type conversions in C.', '3 hours', N'media/uploads/4/chapter-02-variables-and-data-types.png', @CourseId, @SarahId);

-- Course: C++ Algorithms & Data Structures (Sarah Lim)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -35, GETDATE()), 'C++ Algorithms & Data Structures', 'Develop efficient problem-solving skills with C++ algorithms, data structures, and complexity analysis.', 'Hard', '36 hours', @SarahId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C++'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -55, GETDATE()), 1, 'Pointers and Memory', 'Work with pointers, references, and dynamic memory safely and efficiently.', '4 hours', N'media/uploads/5/chapter-01-pointers-and-memory.mp4', @CourseId, @SarahId),
    (DATEADD(DAY, -58, GETDATE()), DATEADD(DAY, -50, GETDATE()), 2, 'Arrays and Vectors', 'Store and process collections of data with arrays and the standard vector container.', '3 hours', N'media/uploads/5/chapter-02-arrays-and-vectors.jpg', @CourseId, @SarahId);

-- Course: Machine Learning with Python (Sarah Lim)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -4, GETDATE()), 'Machine Learning with Python', 'Train and evaluate your first machine learning models in Python, from data preparation to predictions.', 'Hard', '30 hours', @SarahId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Python'));
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Machine Learning'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, 'Machine Learning Foundations', 'Understand supervised learning, features, labels, and how models are trained and tested.', '3 hours', N'media/uploads/6/chapter-01-machine-learning-foundations.png', @CourseId, @SarahId),
    (DATEADD(DAY, -9, GETDATE()), DATEADD(DAY, -5, GETDATE()), 2, 'Training Your First Model', 'Fit a simple model, make predictions, and measure how well it performs.', '4 hours', N'media/uploads/6/chapter-02-training-your-first-model.mp4', @CourseId, @SarahId);

-- ==========================================
-- Teacher portal test data (Backend Phase 2, Step 2.5)
-- Enrolments, a final exam for some courses, a quiz and an assessment, and attempts in each AttemptStatus.
-- AttemptStatus: 'completed' (learner finished and submitted), 'in_progress' (learner is working on it),
--                'incomplete' (learner stopped without finishing).
-- A completed attempt with no Result row is waiting for the teacher to grade it.
-- Courses without learners (Data Analysis, C++, Machine Learning) stay deletable.
-- ==========================================
DECLARE @KylanId INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'ttck0413@gmail.com');
DECLARE @WanId INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'wan1234@gmail.com');
DECLARE @PythonCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = 'Python Programming Fundamentals');
DECLARE @JavaCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = 'Java Programming Masterclass');
DECLARE @CCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = 'C Programming Essentials');
DECLARE @PyChapter1 INT = (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @PythonCourse AND [ChapterNum] = 1);
DECLARE @PyChapter2 INT = (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @PythonCourse AND [ChapterNum] = 2);
DECLARE @QuizId INT, @AssessmentId INT, @PyExamId INT, @CExamId INT, @QuestionId INT, @AttemptId INT;

INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate])
VALUES (@KylanId, @PythonCourse, 2, DATEADD(DAY, -35, GETDATE())), (@KylanId, @JavaCourse, 1, DATEADD(DAY, -20, GETDATE())),
       (@WanId, @PythonCourse, 1, DATEADD(DAY, -30, GETDATE())), (@WanId, @CCourse, 1, DATEADD(DAY, -12, GETDATE()));

-- Python: subchapters, a quiz at the end of chapter 2, an assessment at the end of chapter 1 (a chapter has a quiz OR an assessment, never both), and the final exam
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
VALUES
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 1, 'What is Python?', 'Python is a high-level, interpreted programming language created by Guido van Rossum and first released in 1991. Designed with a strong emphasis on code readability and simplicity, Python allows developers to express concepts in fewer lines of code than might be possible in languages such as C++ or Java. Today, it powers everything from complex machine learning models and data analytics pipelines to backend web development and automation scripts, making it one of the most versatile and highly in-demand languages in the tech industry.', N'media/uploads/1/lesson-01-1-what-is-python.mp4', 10, @PyChapter1, @BryanId),
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 2, 'Installing Python', 'Before writing any code, you need to set up your local development environment. This involves downloading the latest stable release of the Python interpreter from the official Python website and running the installer for your specific operating system. During installation, it is crucial to ensure that Python is added to your system PATH variable, which allows you to execute Python commands globally from your terminal. Finally, we will verify the installation by checking the active version.', NULL, 15, @PyChapter1, @BryanId),
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -35, GETDATE()), 3, 'Your First Program', 'The traditional first step in learning any new programming language is creating a "Hello, World!" program. In this lesson, you will open your code editor, write your very first Python script using the built-in print() function, and execute the file through your command line. We will break down exactly how the Python interpreter reads your text file from top to bottom, parses the instructions, and outputs the resulting message directly to your console screen.', N'media/uploads/1/lesson-01-3-your-first-program.pdf', 20, @PyChapter1, @BryanId),
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -33, GETDATE()), 1, 'Numbers and Strings', 'In programming, data types define what kind of value a variable holds and what mathematical or logical operations can be performed on it. This subchapter dives into Python''s core primitive types: integers for whole numbers, floats for decimal values, and strings for textual data. You will learn how to declare these variables, understand how Python dynamically assigns types in memory, and explore common string manipulation techniques such as concatenation and basic formatting.', N'media/uploads/1/lesson-02-1-numbers-and-strings.jpg', 25, @PyChapter2, @BryanId);

INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
VALUES (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -33, GETDATE()), 'Variables Quiz', 'Check your understanding of variables and data types.', N'media/uploads/1/quiz-variables-quiz.pdf', @PyChapter2, @BryanId);
SET @QuizId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
VALUES (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 'Chapter 1 Assessment', 'Explain how a Python program is run and structured.', N'media/uploads/1/assessment-chapter-1-assessment.pdf', @PyChapter1, @BryanId);
SET @AssessmentId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId])
VALUES (DATEADD(DAY, -30, GETDATE()), NULL, 'Final Course Examination', 'Final exam for Python Programming Fundamentals.', 50, 90, 0, 1, @PythonCourse, @BryanId);
SET @PyExamId = SCOPE_IDENTITY();

-- Quiz: multiple choice only
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId])
VALUES ('Which type does the value 3.5 have in Python?', 'MCQ', 2, 1, @BryanId, @QuizId);
SET @QuestionId = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES ('int', 0, 1, @QuestionId), ('float', 1, 2, @QuestionId), ('str', 0, 3, @QuestionId);

-- Assessment: multiple choice, fill-in-the-blank and coding (the last two are marked by the teacher)
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId])
VALUES ('Which command runs a Python file called app.py?', 'MCQ', 2, 1, @BryanId, @AssessmentId);
SET @QuestionId = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES ('python app.py', 1, 1, @QuestionId), ('run app.py', 0, 2, @QuestionId), ('start python app.py', 0, 3, @QuestionId);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId])
VALUES ('The ____ function shows text on the screen.', 'FillBlank', 3, 2, 'print, print()', @BryanId, @AssessmentId);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId])
VALUES ('Write a program that prints Hello, World!', 'Coding', 5, 3, 'print("Hello, World!")', '3 marks for calling print, 2 marks for the exact text.', @BryanId, @AssessmentId);

-- Exam
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId])
VALUES ('Which keyword defines a function in Python?', 'MCQ', 5, 1, @BryanId, @PyExamId);
SET @QuestionId = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES ('def', 1, 1, @QuestionId), ('func', 0, 2, @QuestionId), ('lambda', 0, 3, @QuestionId);

-- C: a final exam
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId])
VALUES (DATEADD(DAY, -10, GETDATE()), NULL, 'Final Course Examination', 'Final exam for C Programming Essentials.', 60, 60, 1, 0, @CCourse, @SarahId);
SET @CExamId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId])
VALUES ('Who developed the C programming language?', 'MCQ', 5, 1, @SarahId, @CExamId);
SET @QuestionId = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES ('James Gosling', 0, 1, @QuestionId), ('Dennis Ritchie', 1, 2, @QuestionId), ('Guido van Rossum', 0, 3, @QuestionId);

-- Attempts (Python): two waiting to be graded, one graded, one in progress, one incomplete
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(HOUR, -3, GETDATE()), 'completed', @KylanId, @QuizId);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(HOUR, -5, GETDATE()), 'completed', @KylanId, @AssessmentId);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @WanId, @QuizId);
SET @AttemptId = SCOPE_IDENTITY();
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (2, 'A', 100, 'Well done.', @AttemptId);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -1, GETDATE()), 'in_progress', @WanId, @PyExamId);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'incomplete', @WanId, @AssessmentId);

-- Attempts (C): one exam waiting to be graded
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(HOUR, -26, GETDATE()), 'completed', @WanId, @CExamId);


-- ==========================================
-- Learner answers (Backend Phase 4, Step 4.1)
-- AttemptAnswer holds what the learner answered on a submitted attempt, one row per question.
--   Multiple choice: AnswerContent is the chosen MCQ_OptionId. Fill-in-the-blank and coding: the learner's own text.
--   IsCorrect is 'pending' until the teacher grades the attempt, then 'correct' or 'incorrect'. ObtainedScore is 0 until then.
-- The Python quiz attempt by Wan already has a Result, so its answer is already marked.
-- ==========================================
DECLARE @AttKylanQuiz INT = (SELECT [AttemptId] FROM [dbo].[Attempt] WHERE [LearnerId] = @KylanId AND [QuizId] = @QuizId);
DECLARE @AttKylanAssessment INT = (SELECT [AttemptId] FROM [dbo].[Attempt] WHERE [LearnerId] = @KylanId AND [AssessmentId] = @AssessmentId);
DECLARE @AttWanQuiz INT = (SELECT [AttemptId] FROM [dbo].[Attempt] WHERE [LearnerId] = @WanId AND [QuizId] = @QuizId);
DECLARE @AttWanCExam INT = (SELECT [AttemptId] FROM [dbo].[Attempt] WHERE [LearnerId] = @WanId AND [ExamId] = @CExamId);
DECLARE @QuizQ1 INT = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = @QuizId AND [QuestionOrder] = 1);
DECLARE @AsmQ1 INT = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = @AssessmentId AND [QuestionOrder] = 1);
DECLARE @AsmQ2 INT = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = @AssessmentId AND [QuestionOrder] = 2);
DECLARE @AsmQ3 INT = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = @AssessmentId AND [QuestionOrder] = 3);
DECLARE @CExamQ1 INT = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = @CExamId AND [QuestionOrder] = 1);

INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
VALUES
    -- Kylan, Variables Quiz: chose 'int' (wrong)
    (@AttKylanQuiz, @QuizQ1, CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = @QuizQ1 AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, ''),
    -- Kylan, Chapter 1 Assessment: right command, accepted blank, a coding answer missing the comma
    (@AttKylanAssessment, @AsmQ1, CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = @AsmQ1 AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, ''),
    (@AttKylanAssessment, @AsmQ2, 'print()', 'pending', 0, ''),
    (@AttKylanAssessment, @AsmQ3, 'print("Hello World!")', 'pending', 0, ''),
    -- Wan, Variables Quiz (already graded): chose 'float' (right)
    (@AttWanQuiz, @QuizQ1, CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = @QuizQ1 AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 2, ''),
    -- Wan, C final exam: chose 'Dennis Ritchie' (right)
    (@AttWanCExam, @CExamQ1, CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = @CExamQ1 AND [OptionOrder] = 2) AS NVARCHAR(20)), 'pending', 0, '');


-- ==========================================
-- 4. TEACHING ASSISTANT MOCK DATA
-- (TA Dashboard, Courses, Provisional Grading, Forum Moderation, and TA Profile)
-- ==========================================

-- A. Teaching Assistant Applications
DECLARE @AppJayveeId INT, @AppMarcusId INT, @AppChloeId INT, @AppDavidId INT;

INSERT INTO [dbo].[Application] ([RoleApplied], [QualificationName], [CredentialDocument], [ApprovalStatus], [RejectReason], [DateSubmitted], [DateReviewed])
VALUES ('Teaching Assistant', 'Bachelor of Computer Science (Honours)', '~/UploadedCertificates/jayvee_bsc_cert.pdf', 'Approved', NULL, DATEADD(DAY, -45, GETDATE()), DATEADD(DAY, -40, GETDATE()));
SET @AppJayveeId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Application] ([RoleApplied], [QualificationName], [CredentialDocument], [ApprovalStatus], [RejectReason], [DateSubmitted], [DateReviewed])
VALUES ('Teaching Assistant', 'Diploma in Information Technology', '~/UploadedCertificates/marcus_diploma.pdf', 'Approved', NULL, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -28, GETDATE()));
SET @AppMarcusId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Application] ([RoleApplied], [QualificationName], [CredentialDocument], [ApprovalStatus], [RejectReason], [DateSubmitted], [DateReviewed])
VALUES ('Teaching Assistant', 'Certificate in Web Basics', '~/UploadedCertificates/david_doc.pdf', 'Rejected', 'Does not meet minimum teaching qualification requirement.', DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -55, GETDATE()));
SET @AppDavidId = SCOPE_IDENTITY();

-- B. Teaching Assistant Accounts
-- Passwords are all BCrypt cost-12 hash of 'Ta123456'
-- Jayvee Ong: Primary TA for test suite and dashboard verification
INSERT INTO [dbo].[Teaching_Assistant] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [QualificationName], [QualificationDocument], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Jayvee Ong', 'ta1234@gmail.com', '$2a$12$lZ9XOB6tOrmvhXzJRV0On.8WYMveRINXmNAD8xInl.dHHfRN1J.Fq', 24, 'Kuala Lumpur, Malaysia', 'Intermediate', 'Bachelor of Computer Science (Honours)', '~/UploadedCertificates/jayvee_bsc_cert.pdf', 'Active', DATEADD(DAY, -40, GETDATE()), @AppJayveeId);

-- Marcus Vance: Secondary Active TA with advanced level
INSERT INTO [dbo].[Teaching_Assistant] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [QualificationName], [QualificationDocument], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Marcus Vance', 'marcus.ta@edu.com.my', '$2a$12$lZ9XOB6tOrmvhXzJRV0On.8WYMveRINXmNAD8xInl.dHHfRN1J.Fq', 27, 'Penang, Malaysia', 'Advanced', 'Diploma in Information Technology', '~/UploadedCertificates/marcus_diploma.pdf', 'Active', DATEADD(DAY, -28, GETDATE()), @AppMarcusId);

-- Chloe Teo: Junior TA with no grading history (for empty-state testing)
INSERT INTO [dbo].[Teaching_Assistant] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [QualificationName], [QualificationDocument], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('Chloe Teo', 'chloe.ta@edu.com.my', '$2a$12$lZ9XOB6tOrmvhXzJRV0On.8WYMveRINXmNAD8xInl.dHHfRN1J.Fq', 22, 'Johor Bahru, Malaysia', 'Beginner', 'Certified Python Associate', '~/UploadedCertificates/chloe_cert.pdf', 'Active', DATEADD(DAY, -5, GETDATE()), @AppChloeId);

-- David Tan: Inactive TA (for unit testing inactive account login rejection)
INSERT INTO [dbo].[Teaching_Assistant] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [QualificationName], [QualificationDocument], [AccStatus], [DateJoined], [ApplicationId])
VALUES ('David Tan', 'david.ta@edu.com.my', '$2a$12$lZ9XOB6tOrmvhXzJRV0On.8WYMveRINXmNAD8xInl.dHHfRN1J.Fq', 29, 'Melaka, Malaysia', 'Intermediate', NULL, NULL, 'Inactive', DATEADD(DAY, -60, GETDATE()), @AppDavidId);

-- C. Subject Assignments
DECLARE @JayveeId INT = (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'ta1234@gmail.com');
DECLARE @MarcusId INT = (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'marcus.ta@edu.com.my');
DECLARE @ChloeId INT  = (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'chloe.ta@edu.com.my');

DECLARE @SubPython INT = (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Python');
DECLARE @SubC INT      = (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C');
DECLARE @SubJava INT   = (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Java');
DECLARE @SubCpp INT    = (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C++');

INSERT INTO [dbo].[EducatorSubject] ([TeacherId], [TA_Id], [SubjectId])
VALUES
    (NULL, @JayveeId, @SubPython),
    (NULL, @JayveeId, @SubC),
    (NULL, @MarcusId, @SubJava),
    (NULL, @MarcusId, @SubCpp),
    (NULL, @ChloeId,  @SubPython);

-- D. Provisional Grading Progress Mock Data
-- 1) An attempt reviewed by Jayvee Ong and submitted for Teacher verification (Awaiting Approval)
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId])
VALUES ('Reviewed', 'Provisional grading complete: MCQ answers verified. Coding question demonstrates correct structure and outputs as expected.', NULL, @JayveeId, @AttKylanAssessment);

-- 2) An attempt where Jayvee Ong has started a provisional draft (In Progress)
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId])
VALUES ('In Progress', 'Draft review: Multiple choice verified, checking algorithm efficiency.', NULL, @JayveeId, @AttWanCExam);

-- 3) An attempt reviewed by Jayvee Ong and subsequently verified & approved by Teacher Bryan Yeong
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId])
VALUES ('Approved', 'Provisional grading reviewed and confirmed by Bryan Yeong.', @BryanId, @JayveeId, @AttWanQuiz);

-- E. Forum Moderation Mock Data
-- 1) Jayvee Ong flagged a forum question for instructor follow-up
DECLARE @PostVisualStudio INT = (SELECT TOP 1 [PostId] FROM [dbo].[Forum] WHERE [Title] LIKE '%Visual Studio%');
IF (@PostVisualStudio IS NOT NULL)
BEGIN
    INSERT INTO [dbo].[Moderate_Forum] ([PostId], [TA_Id], [ModerateAction], [ModerateReason], [DateModerate])
    VALUES (@PostVisualStudio, @JayveeId, 'Flag', 'Discussion touches on external IDE installation rather than core course syntax; flagged for teacher attention.', DATEADD(HOUR, -6, GETDATE()));
END

-- 2) A spam post hidden by Jayvee Ong (excluded from learner views)
DECLARE @SpamPostId INT;
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId])
VALUES ('Buy Exam Dumps and Solutions', 'Contact Telegram @examcheats for 100% verified exam and quiz answers.', DATEADD(DAY, -1, GETDATE()), @WanId, 'Spam,Offers', NULL);
SET @SpamPostId = SCOPE_IDENTITY();

INSERT INTO [dbo].[Moderate_Forum] ([PostId], [TA_Id], [ModerateAction], [ModerateReason], [DateModerate])
VALUES (@SpamPostId, @JayveeId, 'Hide', 'Commercial spam and academic integrity policy violation.', DATEADD(HOUR, -20, GETDATE()));

-- F. Forum Replies by Teaching Assistants
DECLARE @PostString INT = (SELECT TOP 1 [PostId] FROM [dbo].[Forum] WHERE [Title] LIKE '%What is String in Python%');
IF (@PostString IS NOT NULL)
BEGIN
    INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [TA_Id], [ParentThreadId])
    VALUES ('To add to what Bryan explained: Python strings support indexing and slicing (e.g. s[0:3]), but assigning s[0] = "a" raises a TypeError because strings cannot be mutated in place.', 'No', NULL, @PostString, NULL, NULL, @JayveeId, NULL);
END

IF (@PostVisualStudio IS NOT NULL)
BEGIN
    INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [TA_Id], [ParentThreadId])
    VALUES ('In Visual Studio Installer, ensure the "Desktop development with C++" workload is selected, and verify that MSVC v143 build tools are checked.', 'No', NULL, @PostVisualStudio, NULL, NULL, @MarcusId, NULL);
END

-- G. User Activity Logs
INSERT INTO [dbo].[User_Log] ([StartDateTime], [EndDateTime], [LearnerId], [TeacherId], [TA_Id])
VALUES
    (DATEADD(HOUR, -26, GETDATE()), DATEADD(HOUR, -24, GETDATE()), NULL, NULL, @JayveeId),
    (DATEADD(HOUR, -4, GETDATE()),  DATEADD(HOUR, -2, GETDATE()),  NULL, NULL, @JayveeId),
    (DATEADD(DAY, -2, GETDATE()),   DATEADD(MINUTE, 50, DATEADD(DAY, -2, GETDATE())), NULL, NULL, @MarcusId);

DECLARE @SdQ INT, @SdCourse INT, @SdChapter INT, @SdTest INT, @SdAttempt INT, @SdPost INT, @SdReply INT;
DECLARE @SdAlvin INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'alvinchong@edu.com.my');
DECLARE @SdPriya INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'priyanair@edu.com.my');
DECLARE @SdDaniel INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'danielwong@edu.com.my');
DECLARE @SdMeiling INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'meilingtan@edu.com.my');
DECLARE @SdHafiz INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'hafizrahman@edu.com.my');
DECLARE @SdBryan INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'bryanyeong@edu.com.my');
DECLARE @SdSarah INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'sarahlim@edu.com.my');

-- Teachers (BCrypt cost-12 hashes of Teacher1234!)
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
VALUES
    (N'Alvin Chong', N'alvinchong@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 38, N'Selangor, Malaysia', N'Advanced', N'Active', '2025-11-02', NULL),
    (N'Priya Nair', N'priyanair@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 31, N'Kuala Lumpur, Malaysia', N'Advanced', N'Active', '2025-12-18', NULL),
    (N'Daniel Wong', N'danielwong@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 35, N'Ipoh, Malaysia', N'Intermediate', N'Active', '2026-02-05', NULL),
    (N'Mei Ling Tan', N'meilingtan@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 28, N'Melaka, Malaysia', N'Intermediate', N'Active', '2026-04-22', NULL),
    (N'Hafiz Rahman', N'hafizrahman@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 41, N'Kuantan, Malaysia', N'Advanced', N'Active', '2026-05-30', NULL),
    (N'Grace Lee', N'gracelee@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 27, N'Kuching, Malaysia', N'Beginner', N'Active', '2026-10-25', NULL),
    (N'Omar Farouk', N'omarfarouk@edu.com.my', '$2a$12$DTZsw.PZ6U47OVy70S7GQuuBDfswuCSHBAunIoBdyT23NcEcyv9UG', 45, N'Kota Kinabalu, Malaysia', N'Advanced', N'Inactive', '2025-09-14', NULL);

SET @SdAlvin = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'alvinchong@edu.com.my');
SET @SdPriya = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'priyanair@edu.com.my');
SET @SdDaniel = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'danielwong@edu.com.my');
SET @SdMeiling = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'meilingtan@edu.com.my');
SET @SdHafiz = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'hafizrahman@edu.com.my');

-- Subjects: more learning domains
INSERT INTO [dbo].[Subject] ([SubjectName], [SubjectType]) VALUES (N'Web Development', 'Domain'), (N'Databases', 'Domain'), (N'Cybersecurity', 'Domain'), (N'Algorithms', 'Domain');

-- Learners (BCrypt cost-12 hashes of Learner1234!)
INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES
    (N'Aisyah Rahman', N'aisyah.rahman@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -40, GETDATE()), 'Active', 22, N'Selangor, Malaysia', N'Student'),
    (N'Ben Tan', N'bentan88@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -37, GETDATE()), 'Active', 27, N'Penang, Malaysia', N'Software Tester'),
    (N'Chen Wei', N'chenwei.lee@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -34, GETDATE()), 'Active', 24, N'Johor, Malaysia', N'Student'),
    (N'Divya Menon', N'divya.menon@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -31, GETDATE()), 'Active', 29, N'Kuala Lumpur, Malaysia', N'Data Analyst'),
    (N'Ethan Lim', N'ethanlim2002@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -28, GETDATE()), 'Active', 20, N'Melaka, Malaysia', N'Student'),
    (N'Farah Aziz', N'farah.aziz@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -25, GETDATE()), 'Active', 26, N'Perak, Malaysia', N'Teacher'),
    (N'Gavin Ooi', N'gavinooi@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -22, GETDATE()), 'Active', 31, N'Sabah, Malaysia', N'Engineer'),
    (N'Hana Yusof', N'hana.yusof@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -19, GETDATE()), 'Active', 23, N'Terengganu, Malaysia', N'Student');
DECLARE @SdAisyah INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'aisyah.rahman@gmail.com');
DECLARE @SdBen INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'bentan88@gmail.com');
DECLARE @SdChen INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'chenwei.lee@gmail.com');
DECLARE @SdDivya INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'divya.menon@gmail.com');
DECLARE @SdEthan INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'ethanlim2002@gmail.com');
DECLARE @SdFarah INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'farah.aziz@gmail.com');
DECLARE @SdGavin INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'gavinooi@gmail.com');
DECLARE @SdHana INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'hana.yusof@gmail.com');

-- Courses (with their language and domains), then the chapters of three of them
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -45, GETDATE()), DATEADD(DAY, -20, GETDATE()), N'Web Apps with Python and Flask', N'Build and deploy small web applications with Flask: routes, templates, forms and a database.', N'Medium', N'28 hours', @SdAlvin);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'Python', N'Web Development');
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -50, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Advanced Python Patterns', N'Go beyond the basics with decorators, generators, context managers and clean, testable Python.', N'Hard', N'22 hours', @SdPriya);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'Python');
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -10, GETDATE()), N'Java Collections and Streams', N'Use lists, sets, maps and the Streams API to process data in clear, efficient Java code.', N'Medium', N'18 hours', @SdPriya);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'Java');
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -28, GETDATE()), DATEADD(DAY, -9, GETDATE()), N'Databases with Python', N'Design tables, write SQL queries and connect a database to a Python program.', N'Easy', N'16 hours', @SdDaniel);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'Python', N'Databases');
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'C Pointers Workshop', N'A hands-on workshop that makes pointers, arrays and memory in C easy to reason about.', N'Medium', N'12 hours', @SdHafiz);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'C', N'Algorithms');
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, -3, GETDATE()), N'Cybersecurity Basics with Python', N'Learn common threats and write small Python tools that check passwords, hashes and network ports.', N'Medium', N'20 hours', @SdMeiling);
SET @SdCourse = SCOPE_IDENTITY();
INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
SELECT @SdCourse, [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] IN (N'Python', N'Cybersecurity');

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -45, GETDATE()), DATEADD(DAY, -40, GETDATE()), 1, N'Introduction to Flask', N'Set up Flask, run a development server and return your first page.', N'3 hours', N'media/uploads/7/chapter-01-introduction-to-flask.jpg', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), @SdAlvin),
    (DATEADD(DAY, -43, GETDATE()), DATEADD(DAY, -36, GETDATE()), 2, N'Routes and Templates', N'Map URLs to functions and build pages with Jinja templates.', N'4 hours', N'media/uploads/7/chapter-02-routes-and-templates.png', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), @SdAlvin),
    (DATEADD(DAY, -50, GETDATE()), DATEADD(DAY, -44, GETDATE()), 1, N'Decorators', N'Write functions that wrap other functions, with and without arguments.', N'4 hours', N'media/uploads/8/chapter-01-decorators.mp4', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), @SdPriya),
    (DATEADD(DAY, -48, GETDATE()), DATEADD(DAY, -40, GETDATE()), 2, N'Generators and Iterators', N'Produce values lazily with yield and build your own iterators.', N'3.5 hours', N'media/uploads/8/chapter-02-generators-and-iterators.jpg', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), @SdPriya),
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -30, GETDATE()), 1, N'Lists, Sets and Maps', N'Choose and use the right collection for the job.', N'3 hours', N'media/uploads/9/chapter-01-lists-sets-and-maps.png', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), @SdPriya),
    (DATEADD(DAY, -33, GETDATE()), DATEADD(DAY, -26, GETDATE()), 2, N'Streams in Practice', N'Filter, map and collect data with the Streams API.', N'4 hours', N'media/uploads/9/chapter-02-streams-in-practice.mp4', (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), @SdPriya);

-- Subchapters (duration in minutes)
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
VALUES
    (DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -20, GETDATE()), 1, N'Your First Java Program', N'Writing, compiling, and running your very first Java application. You will learn how to write the classic "Hello, World!" program, understand the role of the Java Development Kit (JDK), compile your .java source code into a .class bytecode file using the javac compiler, and finally execute it using the Java Virtual Machine (JVM). This foundational process forms the backbone of all Java application development.', N'media/uploads/2/lesson-01-1-your-first-java-program.mp4', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass') AND [ChapterNum] = 1), @SdBryan),
    
    (DATEADD(DAY, -31, GETDATE()), DATEADD(DAY, -21, GETDATE()), 2, N'Primitive Types', N'Dive deep into Java''s memory management by exploring its eight primitive data types: byte, short, int, long, float, double, boolean, and char. You will learn the exact memory footprint of each type, their minimum and maximum value ranges, and the best practices for choosing the most efficient type for your specific data needs to optimize application performance and prevent memory overflow errors.', NULL, 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass') AND [ChapterNum] = 1), @SdBryan),
    
    (DATEADD(DAY, -32, GETDATE()), DATEADD(DAY, -22, GETDATE()), 1, N'Classes and Objects', N'Transition into Object-Oriented Programming (OOP) by learning how to define blueprints for your data. You will learn the syntax for creating classes, defining instance variables (fields) to hold object state, and writing methods to define object behavior. Finally, you will instantiate concrete objects from these class blueprints using the ''new'' keyword and interact with them dynamically in memory.', N'media/uploads/2/lesson-02-1-classes-and-objects.jpg', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass') AND [ChapterNum] = 2), @SdBryan),
    
    (DATEADD(DAY, -33, GETDATE()), DATEADD(DAY, -23, GETDATE()), 1, N'Reading a CSV File', N'Data analysis begins with data ingestion. In this lesson, you will learn how to utilize the powerful pandas library to seamlessly read comma-separated values (CSV) files from your local storage directly into a structured, two-dimensional table known as a DataFrame. We will cover file path management, handling different delimiters, and troubleshooting common file-reading and encoding errors.', N'media/uploads/3/lesson-01-1-reading-a-csv-file.mp4', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python') AND [ChapterNum] = 1), @SdBryan),
    
    (DATEADD(DAY, -34, GETDATE()), DATEADD(DAY, -24, GETDATE()), 2, N'First Look at the Data', N'Once your data is loaded into a pandas DataFrame, the next critical step is exploratory data analysis (EDA). You will master essential functions like .head() to preview top rows, .info() to inspect data types and null counts, and .describe() to instantly generate statistical summaries such as mean, standard deviation, and quartile distributions for all numeric columns in your dataset.', NULL, 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python') AND [ChapterNum] = 1), @SdBryan),
    
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'Compiling with gcc', N'Mastering the C programming language requires a solid understanding of the compilation pipeline. In this subchapter, you will use the GNU Compiler Collection (GCC) to translate your human-readable C source code into machine-executable binary code directly from the command line interface. We will explore compiler flags, intermediate object files, and the background linking process that produces your final executable.', N'media/uploads/4/lesson-01-1-compiling-with-gcc.mp4', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials') AND [ChapterNum] = 1), @SdSarah),
    
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -26, GETDATE()), 2, N'The main Function', N'Every C program must have a defined entry and exit point, which is exclusively handled by the main() function. This lesson explores the exact signature of the main function, how the host operating system invokes it upon launch, how it handles external command-line arguments using argc and argv, and the significance of the integer return value used to signal execution success or failure.', NULL, 10, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials') AND [ChapterNum] = 1), @SdSarah),
    
    (DATEADD(DAY, -37, GETDATE()), DATEADD(DAY, -27, GETDATE()), 1, N'What is a Pointer?', N'Unlocking the true performance potential of C++ requires mastering direct memory access. We will demystify pointers by exploring how variables are stored in RAM, how to retrieve their physical hexadecimal memory addresses using the address-of operator (&), how to strictly store those addresses in pointer variables, and how to safely manipulate the underlying values using the dereference operator (*).', N'media/uploads/5/lesson-01-1-what-is-a-pointer.pdf', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures') AND [ChapterNum] = 1), @SdSarah),
    
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -28, GETDATE()), 1, N'Installing Flask', N'Before writing a web application, you must establish an isolated and reproducible development environment. You will learn how to create and activate a Python virtual environment to avoid dependency conflicts, use the pip package manager to install the lightweight Flask framework, and lock your project dependencies into a requirements.txt file for seamless future deployment to production servers.', N'media/uploads/7/lesson-01-1-installing-flask.jpg', 10, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask') AND [ChapterNum] = 1), @SdAlvin),
    
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -29, GETDATE()), 2, N'Hello, Flask', N'With your environment configured, it is time to build your first operational web server. You will learn how to initialize a Flask application instance, define routing functions using Python decorators to map specific URL paths to backend logic, and return HTTP text responses directly to the user''s web browser, culminating in a fully functional local web server listening on port 5000.', NULL, 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask') AND [ChapterNum] = 1), @SdAlvin),
    
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -30, GETDATE()), 1, N'Functions as Objects', N'Python treats functions as first-class citizens, meaning they are dynamically evaluated objects just like integers, strings, or lists. You will learn how to assign functions to variables, store them in data structures, pass them as arguments to other functions, and even return them dynamically from inside other functions. This paradigm is absolutely essential for writing clean, functional, and highly extensible Python code.', N'media/uploads/8/lesson-01-1-functions-as-objects.mp4', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns') AND [ChapterNum] = 1), @SdPriya),
    
    (DATEADD(DAY, -41, GETDATE()), DATEADD(DAY, -31, GETDATE()), 1, N'The yield Keyword', N'Discover how to handle massive data pipelines efficiently using Python generators and lazy evaluation concepts. By replacing the standard return statement with the yield keyword, you can create stateful functions that pause their execution, yield a single memory-efficient value, and resume exactly where they left off upon the next iteration request, drastically reducing RAM consumption compared to building massive in-memory arrays.', N'media/uploads/8/lesson-02-1-the-yield-keyword.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns') AND [ChapterNum] = 2), @SdPriya);

-- Quizzes (multiple choice only; a chapter has a quiz OR an assessment, never both)
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Control Flow Quiz', N'Check your understanding of if statements and loops.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals') AND [ChapterNum] = 3), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which keyword starts a loop that runs while a condition is true?', 'MCQ', 3, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'for', 0, 1, @SdQ), (N'while', 1, 2, @SdQ), (N'if', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What does range(3) produce?', 'MCQ', 2, 2, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'1, 2, 3', 0, 1, @SdQ), (N'0, 1, 2', 1, 2, @SdQ), (N'0, 1, 2, 3', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Java Basics Quiz', N'Check your understanding of Java syntax and types.', N'media/uploads/2/quiz-java-basics-quiz.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass') AND [ChapterNum] = 1), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which method is the entry point of a Java program?', 'MCQ', 3, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'start()', 0, 1, @SdQ), (N'main()', 1, 2, @SdQ), (N'run()', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which type stores true or false?', 'MCQ', 2, 2, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'boolean', 1, 1, @SdQ), (N'int', 0, 2, @SdQ), (N'String', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Loading Data Quiz', N'Check how data is loaded into pandas.', N'media/uploads/3/quiz-loading-data-quiz.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python') AND [ChapterNum] = 1), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which pandas function reads a CSV file?', 'MCQ', 3, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'read_csv', 1, 1, @SdQ), (N'open_csv', 0, 2, @SdQ), (N'load_file', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What is a pandas DataFrame?', 'MCQ', 2, 2, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A table of rows and columns', 1, 1, @SdQ), (N'A single number', 0, 2, @SdQ), (N'A picture', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Introduction to C Quiz', N'Check what you learned about your first C program.', N'media/uploads/4/quiz-introduction-to-c-quiz.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials') AND [ChapterNum] = 1), @SdSarah);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which header declares printf?', 'MCQ', 3, 1, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'<stdlib.h>', 0, 1, @SdQ), (N'<stdio.h>', 1, 2, @SdQ), (N'<math.h>', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which symbol ends a C statement?', 'MCQ', 2, 2, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N';', 1, 1, @SdQ), (N':', 0, 2, @SdQ), (N'.', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Pointers Quiz', N'Check your understanding of pointers in C++.', N'media/uploads/5/quiz-pointers-quiz.jpg', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures') AND [ChapterNum] = 1), @SdSarah);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which operator gives the address of a variable?', 'MCQ', 3, 1, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'&', 1, 1, @SdQ), (N'*', 0, 2, @SdQ), (N'->', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What does *p do for a pointer p?', 'MCQ', 2, 2, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Reads the value p points to', 1, 1, @SdQ), (N'Deletes p', 0, 2, @SdQ), (N'Prints p', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Flask Basics Quiz', N'Check the basics of a Flask application.', N'media/uploads/7/quiz-flask-basics-quiz.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask') AND [ChapterNum] = 1), @SdAlvin);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which decorator maps a URL to a function in Flask?', 'MCQ', 3, 1, @SdAlvin, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'@app.route', 1, 1, @SdQ), (N'@app.url', 0, 2, @SdQ), (N'@route.app', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which command installs Flask?', 'MCQ', 2, 2, @SdAlvin, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'pip install flask', 1, 1, @SdQ), (N'install flask', 0, 2, @SdQ), (N'python flask', 0, 3, @SdQ);
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -18, GETDATE()), N'Decorators Quiz', N'Check how decorators work.', N'media/uploads/8/quiz-decorators-quiz.png', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns') AND [ChapterNum] = 1), @SdPriya);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What does a decorator receive?', 'MCQ', 3, 1, @SdPriya, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A function', 1, 1, @SdQ), (N'A database', 0, 2, @SdQ), (N'A file path', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which symbol applies a decorator?', 'MCQ', 2, 2, @SdPriya, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'@', 1, 1, @SdQ), (N'#', 0, 2, @SdQ), (N'$', 0, 3, @SdQ);

-- Assessments (multiple choice, fill-in-the-blank and coding; the last two are marked by the teacher)
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -17, GETDATE()), N'OOP Assessment', N'Show that you can model a small class in Java.', N'media/uploads/2/assessment-oop-assessment.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass') AND [ChapterNum] = 2), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which keyword creates a subclass in Java?', 'MCQ', 2, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'extends', 1, 1, @SdQ), (N'implements', 0, 2, @SdQ), (N'inherits', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Write a class Dog with a method bark() that prints Woof.', 'Coding', 8, 2, N'class Dog {' + CHAR(13) + CHAR(10) + N'    void bark() {' + CHAR(13) + CHAR(10) + N'        System.out.println("Woof");' + CHAR(13) + CHAR(10) + N'    }' + CHAR(13) + CHAR(10) + N'}', N'3 marks for the class, 3 marks for the method, 2 marks for printing Woof.', @SdBryan, @SdTest);
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -17, GETDATE()), N'Data Cleaning Assessment', N'Clean a small dataset and describe it.', N'media/uploads/3/assessment-data-cleaning-assessment.jpg', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python') AND [ChapterNum] = 2), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which pandas method removes rows with missing values?', 'MCQ', 2, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'dropna', 1, 1, @SdQ), (N'fillna', 0, 2, @SdQ), (N'isna', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId]) VALUES (N'The ____ method shows summary statistics for a DataFrame.', 'FillBlank', 3, 2, N'describe, describe()', @SdBryan, @SdTest);
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -17, GETDATE()), N'Variables in C Assessment', N'Declare and print variables in C.', N'media/uploads/4/assessment-variables-in-c-assessment.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials') AND [ChapterNum] = 2), @SdSarah);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which type stores a single character in C?', 'MCQ', 2, 1, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'char', 1, 1, @SdQ), (N'string', 0, 2, @SdQ), (N'text', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Declare an int called age with the value 20 and print it with printf.', 'Coding', 8, 2, N'int age = 20;' + CHAR(13) + CHAR(10) + N'printf("%d", age);', N'3 marks for the declaration, 3 marks for printf, 2 marks for the correct %d format.', @SdSarah, @SdTest);
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -17, GETDATE()), N'Routes Assessment', N'Write and explain a simple Flask route.', N'media/uploads/7/assessment-routes-assessment.pdf', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask') AND [ChapterNum] = 2), @SdAlvin);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'What does Jinja do in a Flask app?', 'MCQ', 2, 1, @SdAlvin, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Renders HTML templates', 1, 1, @SdQ), (N'Stores files', 0, 2, @SdQ), (N'Compiles code', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Write a Flask route /hello that returns the text Hello.', 'Coding', 8, 2, N'@app.route("/hello")' + CHAR(13) + CHAR(10) + N'def hello():' + CHAR(13) + CHAR(10) + N'    return "Hello"', N'3 marks for the route decorator, 3 marks for the function, 2 marks for returning the text.', @SdAlvin, @SdTest);
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -17, GETDATE()), N'Generators Assessment', N'Write and explain a generator.', N'media/uploads/8/assessment-generators-assessment.png', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns') AND [ChapterNum] = 2), @SdPriya);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId]) VALUES (N'A function that uses ____ instead of return produces a generator.', 'FillBlank', 3, 1, N'yield', @SdPriya, @SdTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Write a generator count_up(n) that yields the numbers 1 to n.', 'Coding', 7, 2, N'def count_up(n):' + CHAR(13) + CHAR(10) + N'    for i in range(1, n + 1):' + CHAR(13) + CHAR(10) + N'        yield i', N'3 marks for the loop, 2 marks for yield, 2 marks for the correct range.', @SdPriya, @SdTest);

-- Final exams (one per course): one multiple choice and one fill-in-the-blank question, 5 marks each
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Java Programming Masterclass.', 50, 90, 1, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which keyword prevents a class from being extended?', 'MCQ', 5, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'final', 1, 1, @SdQ), (N'static', 0, 2, @SdQ), (N'abstract', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'The ____ keyword creates a new object in Java.', 'FillBlank', 5, 2, N'new', @SdBryan, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Data Analysis with Python.', 50, 75, 0, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python'), @SdBryan);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which library is used for data frames in Python?', 'MCQ', 5, 1, @SdBryan, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'pandas', 1, 1, @SdQ), (N'flask', 0, 2, @SdQ), (N'turtle', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'A ____ is a table of rows and columns in pandas.', 'FillBlank', 5, 2, N'DataFrame, dataframe', @SdBryan, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for C++ Algorithms & Data Structures.', 60, 120, 1, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures'), @SdSarah);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which container is a dynamic array in C++?', 'MCQ', 5, 1, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'vector', 1, 1, @SdQ), (N'map', 0, 2, @SdQ), (N'set', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'The ____ operator accesses a member through a pointer.', 'FillBlank', 5, 2, N'->', @SdSarah, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Machine Learning with Python.', 50, 90, 0, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python'), @SdSarah);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'What are the inputs a model learns from called?', 'MCQ', 5, 1, @SdSarah, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'features', 1, 1, @SdQ), (N'outputs', 0, 2, @SdQ), (N'bugs', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'In supervised learning each example has a ____.', 'FillBlank', 5, 2, N'label', @SdSarah, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Web Apps with Python and Flask.', 50, 60, 0, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), @SdAlvin);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which function starts the Flask development server?', 'MCQ', 5, 1, @SdAlvin, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'app.run()', 1, 1, @SdQ), (N'app.start()', 0, 2, @SdQ), (N'flask.go()', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'Flask templates are written with the ____ engine.', 'FillBlank', 5, 2, N'Jinja, Jinja2', @SdAlvin, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Advanced Python Patterns.', 60, 90, 1, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), @SdPriya);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which keyword makes a function produce values one at a time?', 'MCQ', 5, 1, @SdPriya, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'yield', 1, 1, @SdQ), (N'return', 0, 2, @SdQ), (N'pass', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'A ____ wraps another function to add behaviour.', 'FillBlank', 5, 2, N'decorator', @SdPriya, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Java Collections and Streams.', 50, 75, 1, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), @SdPriya);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which collection does not allow duplicates?', 'MCQ', 5, 1, @SdPriya, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Set', 1, 1, @SdQ), (N'List', 0, 2, @SdQ), (N'ArrayList', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'The ____ interface stores key-value pairs in Java.', 'FillBlank', 5, 2, N'Map', @SdPriya, @SdTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId]) VALUES (DATEADD(DAY, -12, GETDATE()), NULL, 'Final Course Examination', N'Final exam for Databases with Python.', 50, 60, 0, 1, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python'), @SdDaniel);
SET @SdTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which SQL command reads rows from a table?', 'MCQ', 5, 1, @SdDaniel, @SdTest);
SET @SdQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'SELECT', 1, 1, @SdQ), (N'INSERT', 0, 2, @SdQ), (N'DELETE', 0, 3, @SdQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'The ____ keyword filters rows in a SQL query.', 'FillBlank', 5, 2, N'WHERE, where', @SdDaniel, @SdTest);

-- Enrolments (ChapNum = the chapter the learner is on)
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate])
VALUES
    (@SdAisyah, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), 3, DATEADD(DAY, -30, GETDATE())),
    (@SdAisyah, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), 2, DATEADD(DAY, -14, GETDATE())),
    (@SdBen, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), 1, DATEADD(DAY, -20, GETDATE())),
    (@SdBen, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'), 1, DATEADD(DAY, -18, GETDATE())),
    (@SdChen, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials'), 2, DATEADD(DAY, -22, GETDATE())),
    (@SdChen, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'), 2, DATEADD(DAY, -16, GETDATE())),
    (@SdDivya, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), 1, DATEADD(DAY, -12, GETDATE())),
    (@SdDivya, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), 2, DATEADD(DAY, -25, GETDATE())),
    (@SdEthan, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), 1, DATEADD(DAY, -10, GETDATE())),
    (@SdEthan, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), 1, DATEADD(DAY, -8, GETDATE())),
    (@SdFarah, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), 3, DATEADD(DAY, -34, GETDATE())),
    (@SdFarah, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), 2, DATEADD(DAY, -17, GETDATE())),
    (@SdGavin, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'), 2, DATEADD(DAY, -26, GETDATE())),
    (@SdGavin, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), 2, DATEADD(DAY, -9, GETDATE())),
    (@SdHana, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials'), 1, DATEADD(DAY, -11, GETDATE())),
    (@SdHana, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), 2, DATEADD(DAY, -13, GETDATE()));

-- Attempts in every AttemptStatus. A completed attempt with no Result is waiting for the teacher to grade it.
-- Quiz: Control Flow Quiz, graded
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @SdAisyah, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -3, GETDATE()), 'completed', @SdFarah, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (3, 'C', 60, N'', @SdAttempt);
-- Java Basics Quiz: incomplete (the learner stopped)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'incomplete', @SdBen, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Java Basics Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
-- Introduction to C Quiz: submitted, the teacher has started grading it
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(HOUR, -6, GETDATE()), 'completed', @SdChen, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'', @SdSarah, NULL, @SdAttempt);
-- Variables in C Assessment: in progress
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -1, GETDATE()), 'in_progress', @SdChen, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Variables in C Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();
-- Flask Basics Quiz: graded F
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -1, GETDATE()), 'completed', @SdEthan, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (2, 'F', 40, N'', @SdAttempt);
-- Routes Assessment: submitted and waiting (a teaching assistant has reviewed it)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(HOUR, -8, GETDATE()), 'completed', @SdHana, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 2), N'@app.route("/hello")' + CHAR(13) + CHAR(10) + N'def hello():' + CHAR(13) + CHAR(10) + N'    return "Hello"', 'pending', 0, N'');
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Provisional marks suggested: MCQ correct, the coding answer follows the marking guide.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'marcus.ta@edu.com.my'), @SdAttempt);
-- Decorators Quiz: graded A
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @SdDivya, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);
-- OOP Assessment: graded B (the coding answer got 5 of 8)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -3, GETDATE()), 'completed', @SdGavin, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 2), N'class Dog { void bark() { System.out.println("Woof"); } }', 'partial', 5, N'Correct idea. Make the method public if other classes will call it.');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (7, 'B', 70, N'Q2: Correct idea. Make the method public if other classes will call it.', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdBryan, NULL, @SdAttempt);
-- Final exams: Python (graded A, certificate), Advanced Python (graded A, certificate), C (graded F), Python (in progress)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -5, GETDATE()), 'completed', @SdFarah, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals')));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals')) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals')) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 5, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdBryan, NULL, @SdAttempt);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'completed', @SdDivya, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 5, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 2), N'decorator', 'correct', 5, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (10, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdPriya, NULL, @SdAttempt);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @SdHana, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (0, 'F', 0, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdSarah, NULL, @SdAttempt);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(HOUR, -3, GETDATE()), 'in_progress', @SdAisyah, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals')));
SET @SdAttempt = SCOPE_IDENTITY();

-- Certificates (issued by the teacher after a passed final exam)
INSERT INTO [dbo].[Certificate] ([Issuer], [IssueDate], [LearnerId], [CourseId]) VALUES
    ('Bryan Yeong', DATEADD(DAY, -5, GETDATE()), @SdFarah, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals')),
    ('Priya Nair', DATEADD(DAY, -4, GETDATE()), @SdDivya, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'));

-- Course reviews
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) VALUES
    (N'Clear explanations and good exercises.', 5, DATEADD(DAY, -4, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), @SdFarah),
    (N'Great pace for beginners.', 4.5, DATEADD(DAY, -6, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'), @SdAisyah),
    (N'Streams finally make sense.', 4, DATEADD(DAY, -3, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), @SdGavin),
    (N'Decorators were explained perfectly.', 5, DATEADD(DAY, -2, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'), @SdDivya),
    (N'Good content, but I wanted more exercises.', 3.5, DATEADD(DAY, -5, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), @SdHana),
    (N'Easy to follow.', 4, DATEADD(DAY, -4, GETDATE()), (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'), @SdEthan);

-- Forum posts and replies (a teacher sees their own posts and those of learners enrolled in their courses)
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'How do list comprehensions work?', N'I keep seeing [x * 2 for x in numbers] in examples. How is a list comprehension different from a normal for loop?', DATEADD(DAY, -3, GETDATE()), @SdAisyah, N'Python,Lists', NULL);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Think of it as a for loop written on one line.', 'No', NULL, @SdPost, @SdFarah, NULL, NULL);
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Exactly. Read it from the left: build x * 2 for every x in numbers. The result is a new list.', 'Yes', DATEADD(DAY, -1, GETDATE()), @SdPost, NULL, @SdBryan, (SELECT [ThreadId] FROM [dbo].[Post_Reply] WHERE [PostId] = @SdPost AND [ReplyComment] = N'Think of it as a for loop written on one line.'));
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'That makes sense now, thank you!', 'No', NULL, @SdPost, @SdAisyah, NULL, (SELECT [ThreadId] FROM [dbo].[Post_Reply] WHERE [PostId] = @SdPost AND [ReplyComment] = N'Exactly. Read it from the left: build x * 2 for every x in numbers. The result is a new list.'));
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Why does my Flask route return 404?', N'I added @app.route("/about") but the page shows Not Found.', DATEADD(DAY, -2, GETDATE()), @SdEthan, N'Flask,Errors', NULL);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Restart the development server after you add a route, and check that the function name is unique.', 'No', NULL, @SdPost, NULL, @SdAlvin, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Segmentation fault when using pointers', N'My program crashes with a segmentation fault when I print *p. What might be wrong?', DATEADD(DAY, -1, GETDATE()), @SdChen, N'C,Pointers', NULL);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Check that p points to valid memory before you dereference it. A pointer that was never assigned is the usual cause.', 'Yes', DATEADD(DAY, -1, GETDATE()), @SdPost, NULL, @SdSarah, NULL);
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'I had the same problem: I forgot to set p = &x.', 'No', NULL, @SdPost, @SdHana, NULL, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'ArrayList or LinkedList?', N'When should I use a LinkedList instead of an ArrayList in Java?', DATEADD(DAY, -4, GETDATE()), @SdGavin, N'Java,Collections', NULL);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Use ArrayList by default. A LinkedList only helps when you insert or remove a lot in the middle of a big list.', 'No', NULL, @SdPost, NULL, @SdPriya, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'What does yield actually do?', N'I understand return, but yield confuses me. Does the function stop?', DATEADD(DAY, -2, GETDATE()), @SdDivya, N'Python,Generators', NULL);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'It pauses the function and gives back one value. The next call carries on from the same place.', 'Yes', DATEADD(DAY, -1, GETDATE()), @SdPost, NULL, @SdPriya, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Welcome to Web Apps with Python and Flask', N'Introduce yourself and share the first small site you would like to build.', DATEADD(DAY, -9, GETDATE()), NULL, N'Announcement', @SdAlvin);
SET @SdPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'I would like to build a simple to-do list.', 'No', NULL, @SdPost, @SdAisyah, NULL, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Office hours this week', N'I will answer questions about Advanced Python Patterns and Java Collections on Thursday evening in this forum.', DATEADD(DAY, -1, GETDATE()), NULL, N'Announcement,Java,Python', @SdPriya);
SET @SdPost = SCOPE_IDENTITY();

-- Teaching subjects of the teachers
INSERT INTO [dbo].[EducatorSubject] ([TeacherId], [TA_Id], [SubjectId]) VALUES
    (@SdBryan, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Python')),
    (@SdBryan, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Java')),
    (@SdSarah, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'C')),
    (@SdSarah, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'C++')),
    (@SdAlvin, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Web Development')),
    (@SdPriya, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Python')),
    (@SdPriya, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Java')),
    (@SdDaniel, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Databases')),
    (@SdHafiz, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Algorithms')),
    (@SdMeiling, NULL, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = N'Cybersecurity'));

PRINT 'Extra teacher sample data inserted.';

-- =========================================================================
-- 6. COMPLETE COURSE DATA & LEARNER JOURNEYS
-- =========================================================================

-- =========================================================================
-- 6.1. NEW LEARNER ACCOUNTS
-- =========================================================================

DECLARE @BcQ INT, @BcTest INT, @BcAttempt INT, @BcPost INT;
DECLARE @BcBryan INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'bryanyeong@edu.com.my');
DECLARE @BcJayvee INT = (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'ta1234@gmail.com');
DECLARE @BcSarah INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'sarahlim@edu.com.my');
DECLARE @BcAlvin INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'alvinchong@edu.com.my');
DECLARE @BcPriya INT = (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'priyanair@edu.com.my');

INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES
    (N'Iman Hakim', N'iman.hakim@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -48, GETDATE()), 'Active', 25, N'Selangor, Malaysia', N'Student'),
    (N'Jason Koh', N'jasonkoh@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -45, GETDATE()), 'Active', 33, N'Kuala Lumpur, Malaysia', N'Accountant'),
    (N'Kavitha Raj', N'kavitha.raj@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -42, GETDATE()), 'Active', 28, N'Penang, Malaysia', N'Graphic Designer'),
    (N'Lucas Ng', N'lucasng99@gmail.com', '$2a$12$9m57m1vam.62oR6GuYghKuf58vk12mGPFwmpicVTfVVlZDHpOzxFu', DATEADD(DAY, -39, GETDATE()), 'Active', 22, N'Johor, Malaysia', N'Student');

-- Account ID Declarations
DECLARE @BcIman INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'iman.hakim@gmail.com');
DECLARE @BcJason INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'jasonkoh@gmail.com');
DECLARE @BcKavitha INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'kavitha.raj@gmail.com');
DECLARE @BcLucas INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'lucasng99@gmail.com');
DECLARE @BcKylan INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'ttck0413@gmail.com');
DECLARE @BcWan INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'wan1234@gmail.com');
DECLARE @BcAisyah INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'aisyah.rahman@gmail.com');
DECLARE @BcBen INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'bentan88@gmail.com');
DECLARE @BcChen INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'chenwei.lee@gmail.com');
DECLARE @BcDivya INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'divya.menon@gmail.com');
DECLARE @BcEthan INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'ethanlim2002@gmail.com');
DECLARE @BcFarah INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'farah.aziz@gmail.com');
DECLARE @BcGavin INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'gavinooi@gmail.com');
DECLARE @BcHana INT = (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = 'hana.yusof@gmail.com');

-- Course ID Declarations
DECLARE @BcPythonCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
DECLARE @BcJavaCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
DECLARE @BcDataCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
DECLARE @BcFlaskCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask');
DECLARE @BcCppCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures');
DECLARE @BcDatabaseCourse INT = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python');


-- =========================================================================
-- 6.2. COURSE STRUCTURES (CHAPTERS & SUBCHAPTERS WITH EXPANDED CONTENT)
-- =========================================================================

-- New chapters (each course now has 5)
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -24, GETDATE()), 4, N'Functions', N'Write reusable functions with parameters, return values and docstrings.', N'4 hours', N'media/uploads/1/chapter-04-functions.mp4', @BcPythonCourse, @BcBryan),
    (DATEADD(DAY, -28, GETDATE()), DATEADD(DAY, -22, GETDATE()), 5, N'Lists, Dictionaries and Files', N'Store collections of data and read and write text files.', N'5 hours', N'media/uploads/1/chapter-05-lists-dictionaries-and-files.png', @BcPythonCourse, @BcBryan),
    (DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -36, GETDATE()), 3, N'Exceptions and Error Handling', N'Handle errors with try, catch and finally and design your own exceptions.', N'4 hours', N'media/uploads/2/chapter-03-exceptions-and-error-handling.mp4', @BcJavaCourse, @BcBryan),
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -33, GETDATE()), 4, N'Collections and Generics', N'Use lists, maps and generics to store and process groups of objects.', N'5 hours', N'media/uploads/2/chapter-04-collections-and-generics.mp4', @BcJavaCourse, @BcBryan),
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -30, GETDATE()), 5, N'Files and Unit Testing', N'Read and write files and check your code with JUnit tests.', N'4 hours', N'media/uploads/2/chapter-05-files-and-unit-testing.mp4', @BcJavaCourse, @BcBryan),
    (DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -48, GETDATE()), 4, N'Aggregation and Grouping', N'Summarise data with groupby, pivot tables and merges.', N'4 hours', N'media/uploads/3/chapter-04-aggregation-and-grouping.mp4', @BcDataCourse, @BcBryan),
    (DATEADD(DAY, -52, GETDATE()), DATEADD(DAY, -44, GETDATE()), 5, N'Telling a Data Story', N'Turn an analysis into a short report that a reader can act on.', N'3 hours', N'media/uploads/3/chapter-05-telling-a-data-story.png', @BcDataCourse, @BcBryan);

-- Subchapters (Expanded Paragraph Content)
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
VALUES
    (DATEADD(DAY, -34, GETDATE()), DATEADD(DAY, -26, GETDATE()), 2, N'Converting Between Types', N'In dynamic languages like Python, converting data from one type to another (type casting) is a frequent requirement. You will learn how to explicitly convert string inputs into performant integers or floats for mathematical calculations, and conversely, how to cast numeric values back into strings for user-facing output using built-in functions like int(), float(), and str().', NULL, 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -27, GETDATE()), 3, N'Working with Strings', N'Strings are powerful arrays of characters. This subchapter explores advanced string manipulation techniques. You will learn how to slice strings to extract specific substrings using index notation, join multiple strings dynamically, format complex text blocks using f-strings, and leverage built-in methods to easily change cases, strip whitespace, and search for specific character patterns.', N'media/uploads/1/lesson-02-3-working-with-strings.mp4', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -28, GETDATE()), 1, N'if, elif and else', N'Control flow allows your program to make intelligent decisions. You will learn how to use logical comparison operators (==, !=, >, <) to evaluate conditions, and write robust if, elif (else if), and else branches to route your application''s logic down different execution paths based on dynamic user input or changing system states.', N'media/uploads/1/lesson-03-1-if-elif-and-else.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -37, GETDATE()), DATEADD(DAY, -29, GETDATE()), 2, N'for Loops', N'Automation is the core of programming. You will master the for loop, an essential construct used to iterate over a defined sequence of items. We will explore how to loop through ranges of numbers, iterate over characters in a string, and cleanly process collections of data without writing repetitive code.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -30, GETDATE()), 3, N'while Loops', N'While loops run continuously as long as a specific condition evaluates to true. You will learn how to design complex game loops or background services, safely manage loop control variables to prevent catastrophic infinite loops, and use break and continue statements to manually interrupt or skip iterations when necessary.', N'media/uploads/1/lesson-03-3-while-loops.mp4', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -31, GETDATE()), 1, N'Defining a Function', N'Functions are reusable blocks of code that perform a single, well-defined action. You will learn the syntax for defining functions using the def keyword, how to name them according to Python conventions, and how modularizing your code dramatically improves overall readability, debugging, and future maintenance by reducing code duplication.', N'media/uploads/1/lesson-04-1-defining-a-function.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -32, GETDATE()), 2, N'Parameters and Return Values', N'To make functions dynamic, they must accept inputs and produce outputs. You will learn how to pass data into functions via required and optional parameters, utilize default argument values, and properly exit the function using the return statement to hand the processed data back to the main application flow.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -41, GETDATE()), DATEADD(DAY, -26, GETDATE()), 3, N'Scope and Docstrings', N'Understanding variable scope—where a variable is accessible in memory—is crucial for avoiding subtle bugs. We will cover the difference between local and global variables. Additionally, you will learn how to write professional docstrings (documentation strings) inside your functions to clearly explain their purpose, arguments, and return types to other developers.', N'media/uploads/1/lesson-04-3-scope-and-docstrings.png', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -27, GETDATE()), 1, N'Lists and Tuples', N'Lists and tuples are Python''s primary ordered data structures. You will learn how to initialize them, append and remove data from lists dynamically, and understand the critical concept of mutability. We will explore why tuples are immutable (unchangeable) and when you should choose them over lists to protect sensitive data sequences.', N'media/uploads/1/lesson-05-1-lists-and-tuples.mp4', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -34, GETDATE()), DATEADD(DAY, -28, GETDATE()), 2, N'Dictionaries', N'Dictionaries store data in highly efficient key-value pairs, acting much like real-world encyclopedias or JSON objects. You will master dictionary initialization, fast key-based lookups, updating existing values, safely handling missing keys, and iterating cleanly through both the keys and values to process complex, unstructured data.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -29, GETDATE()), 3, N'Reading and Writing Files', N'To create useful applications, your code must interact with the host operating system. You will learn how to safely open local text files using context managers (the ''with'' statement) to ensure resources are properly closed, read data line-by-line into your program, and permanently write output logs or results back to the hard drive.', N'media/uploads/1/lesson-05-3-reading-and-writing-files.pdf', 30, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -30, GETDATE()), 3, N'Operators and Input', N'An interactive Java program requires dynamic user input. You will learn how to utilize the Scanner class to capture keyboard input securely, process those inputs using complex arithmetic operators and modular math, and evaluate state using conditional logical operators (AND, OR, NOT) before producing console output.', N'media/uploads/2/lesson-01-3-operators-and-input.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 1), @BcBryan),
    
    (DATEADD(DAY, -37, GETDATE()), DATEADD(DAY, -31, GETDATE()), 2, N'Inheritance and Interfaces', N'Inheritance allows you to build hierarchical class systems, sharing properties between parent and child classes using the ''extends'' keyword to avoid code duplication. You will also learn to define system contracts using interfaces, ensuring that disparate classes guarantee specific behaviors and method signatures without sharing a direct bloodline.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -32, GETDATE()), 3, N'Polymorphism in Practice', N'Polymorphism allows objects of different classes to be treated uniformly through a shared parent interface. You will learn how to write flexible, extensible code that processes diverse object types dynamically at runtime. This module covers method overriding, dynamic method dispatch, and creating highly decoupled software architectures.', N'media/uploads/2/lesson-02-3-polymorphism-in-practice.mp4', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -26, GETDATE()), 1, N'try, catch and finally', N'Robust applications must handle unexpected runtime errors gracefully without crashing. You will learn the syntax of the try-catch block to intercept exceptions, parse the error stack trace, and utilize the finally block to guarantee that system resources (like database connections or open files) are safely released regardless of the execution outcome.', N'media/uploads/2/lesson-03-1-try-catch-and-finally.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -27, GETDATE()), 2, N'Checked and Unchecked Exceptions', N'Java enforces a strict exception taxonomy. You will learn the critical difference between Checked Exceptions (which the compiler forces you to handle, like IOException) and Unchecked Exceptions (runtime logic errors like NullPointerException). We will discuss best practices for declaring exceptions in method signatures using the ''throws'' keyword.', NULL, 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -41, GETDATE()), DATEADD(DAY, -28, GETDATE()), 3, N'Custom Exceptions', N'Standard exceptions do not always cover unique business logic constraints. You will learn how to create your own Custom Exception classes by extending the base Exception or RuntimeException classes. We will implement descriptive error messages and custom attributes to make debugging highly specific application failures significantly easier.', N'media/uploads/2/lesson-03-3-custom-exceptions.mp4', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -29, GETDATE()), 1, N'Lists and Maps', N'Explore the powerful Java Collections Framework. You will master the ArrayList for storing dynamically resizing sequences of objects, and the HashMap for implementing high-speed key-value pair lookups. We will cover initializing collections, basic operations, and how to safely iterate through them using the enhanced for-loop and Iterators.', N'media/uploads/2/lesson-04-1-lists-and-maps.pdf', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -34, GETDATE()), DATEADD(DAY, -30, GETDATE()), 2, N'Generics Basics', N'Generics enforce strict type safety at compile time, eliminating the need for risky class casting. You will learn how to instantiate collections with specific type parameters (e.g., ArrayList<String>), understand the concept of Type Erasure, and even write your own generic classes and methods that can securely process any data type.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -31, GETDATE()), 3, N'Sorting with Comparators', N'Sorting complex custom objects requires defining strict comparison rules. You will learn how to implement the Comparable interface for natural sorting, and construct custom Comparator objects to dynamically sort collections based on specific fields (like sorting a list of Users by age versus sorting them alphabetically by name).', N'media/uploads/2/lesson-04-3-sorting-with-comparators.png', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -32, GETDATE()), 1, N'Reading and Writing Files', N'Transitioning from memory to permanent storage, this subchapter covers Java''s modern NIO.2 package (java.nio.file). You will learn how to seamlessly resolve file paths across different operating systems, handle file existence checks, buffer input streams for performance, and write complex text data to local files securely.', N'media/uploads/2/lesson-05-1-reading-and-writing-files.mp4', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -37, GETDATE()), DATEADD(DAY, -26, GETDATE()), 2, N'Writing JUnit Tests', N'Code is only reliable if it is thoroughly tested. You will be introduced to JUnit 5, the industry-standard testing framework. You will learn how to write discrete unit tests for individual methods, use assertions to automatically verify that actual outputs match expected results, and structure your test classes for maximum coverage.', NULL, 30, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -27, GETDATE()), 3, N'Test-Driven Practice', N'Test-Driven Development (TDD) flips the standard workflow. You will practice writing failing tests before writing any actual application code, using those tests to define the required software behavior. We will explore the Red-Green-Refactor cycle, ultimately resulting in cleaner, modular, and virtually bug-free production systems.', N'media/uploads/2/lesson-05-3-test-driven-practice.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -28, GETDATE()), 3, N'Selecting Rows and Columns', N'Precise data extraction is a critical skill in pandas. You will learn the fundamental differences between label-based indexing using .loc[] and integer-position-based indexing using .iloc[]. We will cover techniques for slicing specific row ranges, isolating multiple distinct columns, and creating targeted subsets of your massive DataFrames for focused analysis.', N'media/uploads/3/lesson-01-3-selecting-rows-and-columns.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 1), @BcBryan),
    
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -29, GETDATE()), 1, N'Missing Values', N'Real-world data is rarely perfect; it is often riddled with null or missing values that can completely crash analytical functions. You will learn strategies for identifying these gaps using isna(), making informed decisions on whether to safely drop missing rows, or intelligently filling the gaps using statistical means, medians, or forward-fill methodologies.', N'media/uploads/3/lesson-02-1-missing-values.jpg', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -41, GETDATE()), DATEADD(DAY, -30, GETDATE()), 2, N'Fixing Data Types', N'Incorrectly formatted data types prevent accurate calculations. You will learn how to utilize the astype() function to forcibly convert messy string inputs into clean numeric types, leverage pandas'' built-in datetime module to correctly parse and format time-series data, and convert low-cardinality text columns into memory-efficient Category types.', NULL, 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -31, GETDATE()), 3, N'Filtering and Sorting', N'Learn to isolate the exact data you need by applying complex Boolean filters across multiple columns simultaneously. You will write conditions to extract specific demographics or date ranges, and use sort_values() to cleanly organize the resulting DataFrame based on specific numerical or alphabetical hierarchies for easier visual inspection.', N'media/uploads/3/lesson-02-3-filtering-and-sorting.mp4', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 2), @BcBryan),
    
    (DATEADD(DAY, -34, GETDATE()), DATEADD(DAY, -32, GETDATE()), 1, N'Line and Bar Charts', N'Visual communication is often more impactful than raw tables. We will introduce the Matplotlib library to generate fundamental data visualizations. You will learn how to plot simple line charts to track trends over time, and construct comparative bar charts, customizing the axes, labels, and color palettes to create a professional final render.', N'media/uploads/3/lesson-03-1-line-and-bar-charts.pdf', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -26, GETDATE()), 2, N'Histograms and Box Plots', N'Statistical visualization helps identify anomalies. You will construct histograms to visualize the frequency distribution of continuous variables, understanding how bin sizes alter the narrative. We will also build robust Box Plots to instantly identify the median, interquartile ranges, and statistically significant outliers hidden deep within the dataset.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -27, GETDATE()), 3, N'Choosing the Right Chart', N'Generating a chart is easy; selecting the correct chart type is an analytical skill. This conceptual lesson guides you through standard industry best practices for matching specific data dimensions (comparisons, compositions, distributions, and relationships) to the appropriate visualization format to ensure your message is immediately understood by the audience.', N'media/uploads/3/lesson-03-3-choosing-the-right-chart.mp4', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 3), @BcBryan),
    
    (DATEADD(DAY, -37, GETDATE()), DATEADD(DAY, -28, GETDATE()), 1, N'groupby Basics', N'The core of advanced pandas analysis lies in aggregation. You will master the .groupby() function, learning the "split-apply-combine" methodology. You will split large datasets into logical sub-groups based on categorical columns, apply statistical functions like .sum() or .mean() to those isolated groups, and combine the results back into a clean summary table.', N'media/uploads/3/lesson-04-1-groupby-basics.pdf', 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -29, GETDATE()), 2, N'Pivot Tables', N'Familiar to spreadsheet users, pivot tables offer multi-dimensional data aggregation. You will learn how to utilize the pandas pivot_table function to reshape flat datasets, setting specific indices and columns, and applying complex aggregation functions to dynamically cross-tabulate variables and uncover deep, multi-layered statistical insights.', NULL, 25, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -30, GETDATE()), 3, N'Merging DataFrames', N'Enterprise environments rarely store all necessary data in a single file. You will learn relational algebra concepts to merge separate DataFrames together using a shared identifier column. We will explore the vital differences between Inner, Outer, Left, and Right joins to ensure no critical data is accidentally dropped during the consolidation process.', N'media/uploads/3/lesson-04-3-merging-dataframes.png', 30, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 4), @BcBryan),
    
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -31, GETDATE()), 1, N'Framing a Question', N'Data analysis must be purpose-driven. Before writing any code, an analyst must frame a clear, measurable business question. This conceptual subchapter teaches you how to interview stakeholders, identify the core problem, determine what specific metrics are required to provide a solution, and structure your analytical workflow to stay rigorously on track.', N'media/uploads/3/lesson-05-1-framing-a-question.mp4', 15, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -41, GETDATE()), DATEADD(DAY, -32, GETDATE()), 2, N'Building the Report', N'Learn how to synthesize raw code, statistical outputs, and polished visualizations into a cohesive narrative structure. We will cover how to seamlessly blend technical methodology with plain-language interpretations, ensuring that your final report is both reproducible by other data scientists and easily digestible by non-technical business executives.', NULL, 30, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 5), @BcBryan),
    
    (DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -26, GETDATE()), 3, N'Presenting Findings', N'The final step of the analytical lifecycle is delivering the results. You will learn essential presentation skills specific to data science, focusing on how to highlight the most critical insights, address data limitations transparently, and confidently deliver clear, actionable business recommendations based directly on the statistical evidence you compiled.', N'media/uploads/3/lesson-05-3-presenting-findings.pdf', 20, (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 5), @BcBryan);

-- =========================================================================
-- 6.3. QUIZZES, ASSESSMENTS, & EXAMS (WITH QUESTIONS)
-- =========================================================================

-- Quizzes
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Charts Quiz', N'Check how to choose and draw a chart.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 3), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which chart shows how values are distributed?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Histogram', 1, 1, @BcQ), (N'Line of IDs', 0, 2, @BcQ), (N'Map', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which library draws charts in Python?', 'MCQ', 2, 2, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'matplotlib', 1, 1, @BcQ), (N'flask', 0, 2, @BcQ), (N'django', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which chart best shows change over time?', 'MCQ', 2, 3, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Line chart', 1, 1, @BcQ), (N'Pie chart', 0, 2, @BcQ), (N'Table of names', 0, 3, @BcQ);

INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Collections Quiz', N'Check lists and dictionaries.', N'media/uploads/1/quiz-collections-quiz.png', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 5), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which brackets create a list in Python?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'[ ]', 1, 1, @BcQ), (N'{ }', 0, 2, @BcQ), (N'( )', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'How do you read the value for the key "a" in a dictionary d?', 'MCQ', 2, 2, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'd["a"]', 1, 1, @BcQ), (N'd.a', 0, 2, @BcQ), (N'd(a)', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which method adds an item to the end of a list?', 'MCQ', 2, 3, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'append', 1, 1, @BcQ), (N'push', 0, 2, @BcQ), (N'add', 0, 3, @BcQ);

INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Exceptions Quiz', N'Check how Java handles errors.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 3), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which block always runs, even after an exception?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'finally', 1, 1, @BcQ), (N'catch', 0, 2, @BcQ), (N'try', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which keyword throws an exception?', 'MCQ', 2, 2, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'throw', 1, 1, @BcQ), (N'throws', 0, 2, @BcQ), (N'raise', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which of these is a checked exception?', 'MCQ', 2, 3, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'IOException', 1, 1, @BcQ), (N'NullPointerException', 0, 2, @BcQ), (N'ArithmeticException', 0, 3, @BcQ);

INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Testing Quiz', N'Check the basics of unit testing.', N'media/uploads/2/quiz-testing-quiz.jpg', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 5), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which annotation marks a JUnit 5 test method?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'@Test', 1, 1, @BcQ), (N'@Check', 0, 2, @BcQ), (N'@Run', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What does an assertion do?', 'MCQ', 2, 2, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Checks that a result is what you expect', 1, 1, @BcQ), (N'Prints a message', 0, 2, @BcQ), (N'Compiles the code', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Which tool builds and runs the tests of many Java projects?', 'MCQ', 2, 3, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Maven', 1, 1, @BcQ), (N'Notepad', 0, 2, @BcQ), (N'Paint', 0, 3, @BcQ);

INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Reporting Quiz', N'Check how to write a clear data report.', N'media/uploads/3/quiz-reporting-quiz.png', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 5), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What should a data story start with?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A clear question', 1, 1, @BcQ), (N'A random chart', 0, 2, @BcQ), (N'The final slide', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'What makes a good chart title?', 'MCQ', 2, 2, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A short description of the finding', 1, 1, @BcQ), (N'The file name', 0, 2, @BcQ), (N'The column names', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [QuizId]) VALUES (N'Who is the report written for?', 'MCQ', 2, 3, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The reader', 1, 1, @BcQ), (N'The programmer only', 0, 2, @BcQ), (N'Nobody', 0, 3, @BcQ);

-- Assessments
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Functions Assessment', N'Write and explain small Python functions.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcPythonCourse AND [ChapterNum] = 4), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which keyword defines a function?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'def', 1, 1, @BcQ), (N'func', 0, 2, @BcQ), (N'function', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId]) VALUES (N'A function sends a value back with the ____ keyword.', 'FillBlank', 3, 2, N'return', @BcBryan, @BcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Write a function square(n) that returns n multiplied by itself.', 'Coding', 5, 3, N'def square(n):' + CHAR(13) + CHAR(10) + N'    return n * n', N'2 marks for def, 2 marks for the parameter, 1 mark for return.', @BcBryan, @BcTest);

INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Collections Assessment', N'Use Java collections in small programs.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcJavaCourse AND [ChapterNum] = 4), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which interface stores key-value pairs?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Map', 1, 1, @BcQ), (N'List', 0, 2, @BcQ), (N'Set', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId]) VALUES (N'A ____ does not allow duplicate elements.', 'FillBlank', 3, 2, N'Set, set', @BcBryan, @BcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Create an ArrayList<String> called names and add the name Sam.', 'Coding', 5, 3, N'ArrayList<String> names = new ArrayList<>();' + CHAR(13) + CHAR(10) + N'names.add("Sam");', N'2 marks for the list, 2 marks for the generic type, 1 mark for add.', @BcBryan, @BcTest);

INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [ChapterId], [TeacherId]) VALUES (DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -16, GETDATE()), N'Grouping Assessment', N'Summarise data with groupby and merge.', (SELECT [ChapterId] FROM [dbo].[Chapter] WHERE [CourseId] = @BcDataCourse AND [ChapterNum] = 4), @BcBryan);
SET @BcTest = SCOPE_IDENTITY();
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [AssessmentId]) VALUES (N'Which method groups rows by a column?', 'MCQ', 2, 1, @BcBryan, @BcTest);
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'groupby', 1, 1, @BcQ), (N'sortby', 0, 2, @BcQ), (N'merge', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [AssessmentId]) VALUES (N'The ____ method combines two DataFrames on a shared column.', 'FillBlank', 3, 2, N'merge, merge()', @BcBryan, @BcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [AssessmentId]) VALUES (N'Write code that groups df by "city" and gets the mean of "sales".', 'Coding', 5, 3, N'df.groupby("city")["sales"].mean()', N'2 marks for groupby, 2 marks for choosing the column, 1 mark for mean.', @BcBryan, @BcTest);

-- Final Exams
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [TeacherId], [ExamId]) VALUES (N'The ____ function returns the number of items in a list.', 'FillBlank', 5, 2, N'len, len()', @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'What does 7 // 2 give in Python?', 'MCQ', 5, 3, @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3', 1, 1, @BcQ), (N'3.5', 0, 2, @BcQ), (N'4', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [ExamId]) VALUES (N'Write a program that prints the numbers 1 to 5, one per line.', 'Coding', 5, 4, N'for i in range(1, 6):' + CHAR(13) + CHAR(10) + N'    print(i)', N'2 marks for the loop, 2 marks for the range, 1 mark for print.', @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));

INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which keyword lets a class inherit from another class?', 'MCQ', 5, 3, @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcJavaCourse));
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'extends', 1, 1, @BcQ), (N'implements', 0, 2, @BcQ), (N'import', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [ExamId]) VALUES (N'Write a method isEven(int n) that returns true when n is even.', 'Coding', 5, 4, N'boolean isEven(int n) {' + CHAR(13) + CHAR(10) + N'    return n % 2 == 0;' + CHAR(13) + CHAR(10) + N'}', N'2 marks for the signature, 2 marks for the test, 1 mark for returning the result.', @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcJavaCourse));

INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [TeacherId], [ExamId]) VALUES (N'Which method shows the first rows of a DataFrame?', 'MCQ', 5, 3, @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcDataCourse));
SET @BcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'head', 1, 1, @BcQ), (N'top', 0, 2, @BcQ), (N'first', 0, 3, @BcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [ModelAnswer], [MarkingGuide], [TeacherId], [ExamId]) VALUES (N'Write code that drops the rows with missing values from df.', 'Coding', 5, 4, N'df = df.dropna()', N'3 marks for dropna, 2 marks for assigning the result.', @BcBryan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcDataCourse));


-- =========================================================================
-- 6.4. CUSTOM JOURNEYS FOR WAN HON KIT & KYLAN SHANE SEDRICK
-- =========================================================================

-- Safely clean up old Phase 2 mock data in correct foreign key dependency order
DELETE FROM [dbo].[AttemptAnswer] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId IN (@BcKylan, @BcWan));
DELETE FROM [dbo].[Result] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId IN (@BcKylan, @BcWan));
DELETE FROM [dbo].[GradingProgress] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId IN (@BcKylan, @BcWan));
DELETE FROM [dbo].[Attempt] WHERE LearnerId IN (@BcKylan, @BcWan);

DELETE FROM [dbo].[LearnerProgress] WHERE LearnerId IN (@BcKylan, @BcWan);
DELETE FROM [dbo].[Certificate] WHERE LearnerId IN (@BcKylan, @BcWan);
DELETE FROM [dbo].[Course_Review] WHERE LearnerId IN (@BcKylan, @BcWan);

-- 6.4.1. ENROLLMENTS & CURRENT CHAPTER PROGRESS
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate])
VALUES
    -- Kylan's Progress: Finished Python & Data Analysis (Chap 7), Ongoing Java (Ch 3), New Flask (Ch 1)
    (@BcKylan, @BcPythonCourse, 7, DATEADD(DAY, -45, GETDATE())),
    (@BcKylan, @BcDataCourse, 7, DATEADD(DAY, -30, GETDATE())),
    (@BcKylan, @BcJavaCourse, 3, DATEADD(DAY, -15, GETDATE())),
    (@BcKylan, @BcFlaskCourse, 1, DATEADD(DAY, -2, GETDATE())),

    -- Wan's Progress: Finished Java (Chap 7) & C++ (Chap 4), Ongoing Python (Ch 4), New Databases (Ch 1)
    (@BcWan, @BcJavaCourse, 7, DATEADD(DAY, -50, GETDATE())),
    (@BcWan, @BcCppCourse, 4, DATEADD(DAY, -35, GETDATE())), 
    (@BcWan, @BcPythonCourse, 4, DATEADD(DAY, -12, GETDATE())),
    (@BcWan, @BcDatabaseCourse, 1, DATEADD(DAY, -1, GETDATE()));


-- ==========================================================
-- 6.4.2. AUTO-COMPLETE ALL PAST QUIZZES & ASSESSMENTS
-- ==========================================================
DECLARE @DynAttempt INT;

-- === KYLAN'S PAST ATTEMPTS ===
-- Python (Chapters 1 to 5)
DECLARE @KylanTests TABLE (TestName NVARCHAR(100), IsQuiz BIT);
INSERT INTO @KylanTests VALUES ('Chapter 1 Assessment', 0), ('Variables Quiz', 1), ('Control Flow Quiz', 1), ('Functions Assessment', 0), ('Collections Quiz', 1), 
                               ('Loading Data Quiz', 1), ('Data Cleaning Assessment', 0), ('Charts Quiz', 1), ('Grouping Assessment', 0), ('Reporting Quiz', 1),
                               ('Java Basics Quiz', 1), ('OOP Assessment', 0);

DECLARE @TestName NVARCHAR(100), @IsQuiz BIT;
DECLARE KylanCursor CURSOR FOR SELECT TestName, IsQuiz FROM @KylanTests;
OPEN KylanCursor; FETCH NEXT FROM KylanCursor INTO @TestName, @IsQuiz;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @IsQuiz = 1
        INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -20, GETDATE()), 'completed', @BcKylan, (SELECT QuizId FROM Quiz WHERE QuizTitle = @TestName));
    ELSE
        INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -20, GETDATE()), 'completed', @BcKylan, (SELECT AssessmentId FROM Assessment WHERE AssessmentTitle = @TestName));
    
    SET @DynAttempt = SCOPE_IDENTITY();
    
    INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
    SELECT @DynAttempt, QuestionId, 
           CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1)
                WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 
           'correct', QuestionScore, 'Well done' 
    FROM Question q WHERE (@IsQuiz = 1 AND QuizId = (SELECT QuizId FROM Quiz WHERE QuizTitle = @TestName)) OR (@IsQuiz = 0 AND AssessmentId = (SELECT AssessmentId FROM Assessment WHERE AssessmentTitle = @TestName));
    
    INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (10, 'A', 100, 'Perfect', @DynAttempt);
    INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', '', @BcBryan, @DynAttempt);
    FETCH NEXT FROM KylanCursor INTO @TestName, @IsQuiz;
END;
CLOSE KylanCursor; DEALLOCATE KylanCursor;

-- === WAN'S PAST ATTEMPTS ===
DECLARE @WanTests TABLE (TestName NVARCHAR(100), IsQuiz BIT);
INSERT INTO @WanTests VALUES ('Java Basics Quiz', 1), ('OOP Assessment', 0), ('Exceptions Quiz', 1), ('Collections Assessment', 0), ('Testing Quiz', 1),
                             ('Pointers Quiz', 1), ('Chapter 1 Assessment', 0), ('Variables Quiz', 1), ('Control Flow Quiz', 1);

DECLARE WanCursor CURSOR FOR SELECT TestName, IsQuiz FROM @WanTests;
OPEN WanCursor; FETCH NEXT FROM WanCursor INTO @TestName, @IsQuiz;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @IsQuiz = 1
        INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -20, GETDATE()), 'completed', @BcWan, (SELECT QuizId FROM Quiz WHERE QuizTitle = @TestName));
    ELSE
        INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -20, GETDATE()), 'completed', @BcWan, (SELECT AssessmentId FROM Assessment WHERE AssessmentTitle = @TestName));
    
    SET @DynAttempt = SCOPE_IDENTITY();
    
    INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
    SELECT @DynAttempt, QuestionId, 
           CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1)
                WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 
           'correct', QuestionScore, 'Great job' 
    FROM Question q WHERE (@IsQuiz = 1 AND QuizId = (SELECT QuizId FROM Quiz WHERE QuizTitle = @TestName)) OR (@IsQuiz = 0 AND AssessmentId = (SELECT AssessmentId FROM Assessment WHERE AssessmentTitle = @TestName));
    
    INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (10, 'A', 100, 'Perfect', @DynAttempt);
    INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', '', @BcBryan, @DynAttempt);
    FETCH NEXT FROM WanCursor INTO @TestName, @IsQuiz;
END;
CLOSE WanCursor; DEALLOCATE WanCursor;


-- 6.4.3. COMPLETED FINAL EXAMS
-- Kylan: Python Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -10, GETDATE()), 'completed', @BcKylan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT @BcAttempt, QuestionId, CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1) WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 'correct', QuestionScore, '' FROM Question q WHERE ExamId = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse);
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (20, 'A', 100.0, N'Excellent work.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', N'', @BcBryan, @BcAttempt);

-- Kylan: Data Analysis Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -5, GETDATE()), 'completed', @BcKylan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcDataCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT @BcAttempt, QuestionId, CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1) WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 'correct', QuestionScore, '' FROM Question q WHERE ExamId = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcDataCourse);
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (20, 'A', 100.0, N'Great analysis.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', N'', @BcBryan, @BcAttempt);

-- Wan: Java Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -15, GETDATE()), 'completed', @BcWan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcJavaCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT @BcAttempt, QuestionId, CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1) WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 'correct', QuestionScore, '' FROM Question q WHERE ExamId = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcJavaCourse);
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (20, 'A', 100.0, N'Perfect architecture.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', N'', @BcBryan, @BcAttempt);

-- Wan: C++ Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'completed', @BcWan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcCppCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT @BcAttempt, QuestionId, CASE WHEN QuestionType = 'MCQ' THEN (SELECT TOP 1 CAST(MCQ_OptionId AS NVARCHAR(20)) FROM MCQ_Option WHERE QuestionId = q.QuestionId AND IsCorrect = 1) WHEN QuestionType = 'Coding' THEN ModelAnswer ELSE ISNULL(AcceptedAnswers, 'Completed') END, 'correct', QuestionScore, '' FROM Question q WHERE ExamId = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcCppCourse);
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (10, 'B', 80.0, N'Good pointer logic.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [AttemptId]) VALUES ('completed', N'', @BcSarah, @BcAttempt);


-- 6.4.4. IN-PROGRESS ATTEMPTS (Current Chapters)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(HOUR, -2, GETDATE()), 'in_progress', @BcKylan, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Exceptions Quiz')); -- Note: UI considers all unfinished past components
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(HOUR, -1, GETDATE()), 'in_progress', @BcWan, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Functions Assessment'));


-- 6.4.5. CERTIFICATES ISSUED
INSERT INTO [dbo].[Certificate] ([Issuer], [IssueDate], [LearnerId], [CourseId]) VALUES
    ('Bryan Yeong', DATEADD(DAY, -10, GETDATE()), @BcKylan, @BcPythonCourse),
    ('Bryan Yeong', DATEADD(DAY, -5, GETDATE()), @BcKylan, @BcDataCourse),
    ('Bryan Yeong', DATEADD(DAY, -15, GETDATE()), @BcWan, @BcJavaCourse),
    ('Sarah Lim', DATEADD(DAY, -4, GETDATE()), @BcWan, @BcCppCourse);


-- 6.4.6. COURSE REVIEWS
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) VALUES
    (N'Incredible Python course! Very hands-on.', 5, DATEADD(DAY, -9, GETDATE()), @BcPythonCourse, @BcKylan),
    (N'Data analysis made simple.', 4.5, DATEADD(DAY, -4, GETDATE()), @BcDataCourse, @BcKylan),
    (N'Java is tough, but the instructor was great.', 4, DATEADD(DAY, -14, GETDATE()), @BcJavaCourse, @BcWan),
    (N'Loved the C++ pointers lesson!', 5, DATEADD(DAY, -3, GETDATE()), @BcCppCourse, @BcWan);

-- =========================================================================
-- 6.5. GENERAL MOCK LEARNER ENROLLMENTS & ATTEMPTS
-- =========================================================================
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate])
VALUES
    (@BcIman, @BcPythonCourse, 4, DATEADD(DAY, -40, GETDATE())),
    (@BcJason, @BcPythonCourse, 2, DATEADD(DAY, -28, GETDATE())),
    (@BcKavitha, @BcPythonCourse, 5, DATEADD(DAY, -45, GETDATE())),
    (@BcLucas, @BcPythonCourse, 1, DATEADD(DAY, -9, GETDATE())),
    (@BcAisyah, @BcJavaCourse, 3, DATEADD(DAY, -24, GETDATE())),
    (@BcJason, @BcJavaCourse, 4, DATEADD(DAY, -30, GETDATE())),
    (@BcKavitha, @BcJavaCourse, 5, DATEADD(DAY, -33, GETDATE())),
    (@BcLucas, @BcJavaCourse, 1, DATEADD(DAY, -7, GETDATE())),
    (@BcEthan, @BcJavaCourse, 2, DATEADD(DAY, -15, GETDATE())),
    (@BcAisyah, @BcDataCourse, 2, DATEADD(DAY, -21, GETDATE())),
    (@BcDivya, @BcDataCourse, 5, DATEADD(DAY, -35, GETDATE())),
    (@BcEthan, @BcDataCourse, 4, DATEADD(DAY, -19, GETDATE())),
    (@BcFarah, @BcDataCourse, 3, DATEADD(DAY, -22, GETDATE())),
    (@BcHana, @BcDataCourse, 1, DATEADD(DAY, -14, GETDATE())),
    (@BcIman, @BcDataCourse, 2, DATEADD(DAY, -16, GETDATE())),
    (@BcKavitha, @BcDataCourse, 5, DATEADD(DAY, -31, GETDATE())),
    (@BcJason, @BcDataCourse, 3, DATEADD(DAY, -26, GETDATE()));


-- Attempts in every AttemptStatus for General Mock Learners
-- Quiz: Control Flow Quiz, graded
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @SdAisyah, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -3, GETDATE()), 'completed', @BcFarah, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Control Flow Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (3, 'C', 60, N'', @SdAttempt);

-- Java Basics Quiz: incomplete (the learner stopped)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'incomplete', @BcBen, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Java Basics Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();

-- Introduction to C Quiz: submitted, the teacher has started grading it
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(HOUR, -6, GETDATE()), 'completed', @BcChen, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Introduction to C Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'', @SdSarah, NULL, @SdAttempt);

-- Variables in C Assessment: in progress
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -1, GETDATE()), 'in_progress', @BcChen, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Variables in C Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();

-- Flask Basics Quiz: graded F
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -1, GETDATE()), 'completed', @BcEthan, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 2) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Flask Basics Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (2, 'F', 40, N'', @SdAttempt);

-- Routes Assessment: submitted and waiting (a teaching assistant has reviewed it)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(HOUR, -8, GETDATE()), 'completed', @SdHana, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'pending', 0, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Routes Assessment') AND [QuestionOrder] = 2), N'@app.route("/hello")' + CHAR(13) + CHAR(10) + N'def hello():' + CHAR(13) + CHAR(10) + N'    return "Hello"', 'pending', 0, N'');
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Provisional marks suggested: MCQ correct, the coding answer follows the marking guide.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = 'marcus.ta@edu.com.my'), @SdAttempt);

-- Decorators Quiz: graded A
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @BcDivya, (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 3, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 2), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [QuizId] = (SELECT [QuizId] FROM [dbo].[Quiz] WHERE [QuizTitle] = N'Decorators Quiz') AND [QuestionOrder] = 2) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);

-- OOP Assessment: graded B (the coding answer got 5 of 8)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) VALUES (DATEADD(DAY, -3, GETDATE()), 'completed', @BcGavin, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment'));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 2, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [AssessmentId] = (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment') AND [QuestionOrder] = 2), N'class Dog { void bark() { System.out.println("Woof"); } }', 'partial', 5, N'Correct idea. Make the method public if other classes will call it.');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (7, 'B', 70, N'Q2: Correct idea. Make the method public if other classes will call it.', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @BcBryan, NULL, @SdAttempt);

-- Final exams: Python (graded A, certificate), Advanced Python (graded A, certificate), C (graded F), Python (in progress)
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -5, GETDATE()), 'completed', @BcFarah, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 5, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (5, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @BcBryan, NULL, @SdAttempt);

INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -4, GETDATE()), 'completed', @BcDivya, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'correct', 5, N'');
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns')) AND [QuestionOrder] = 2), N'decorator', 'correct', 5, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (10, 'A', 100, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdPriya, NULL, @SdAttempt);

INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(DAY, -2, GETDATE()), 'completed', @BcHana, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')));
SET @SdAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment]) VALUES (@SdAttempt, (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')) AND [QuestionOrder] = 1), CAST((SELECT [MCQ_OptionId] FROM [dbo].[MCQ_Option] WHERE [QuestionId] = (SELECT [QuestionId] FROM [dbo].[Question] WHERE [ExamId] = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials')) AND [QuestionOrder] = 1) AND [OptionOrder] = 1) AS NVARCHAR(20)), 'incorrect', 0, N'');
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (0, 'F', 0, N'', @SdAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @SdSarah, NULL, @SdAttempt);

INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) VALUES (DATEADD(HOUR, -3, GETDATE()), 'in_progress', @BcAisyah, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
SET @SdAttempt = SCOPE_IDENTITY();

-- Certificates (issued by the teacher after a passed final exam)
INSERT INTO [dbo].[Certificate] ([Issuer], [IssueDate], [LearnerId], [CourseId]) VALUES
    ('Bryan Yeong', DATEADD(DAY, -5, GETDATE()), @BcFarah, @BcPythonCourse),
    ('Priya Nair', DATEADD(DAY, -4, GETDATE()), @BcDivya, (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'));

PRINT 'Complete data for learners inserted successfully.';

-- =========================================================================
-- 7. CONTENT TOP-UP: COMPLETE SUBCHAPTERS AND READY-TO-ANSWER TESTS FOR EVERY COURSE
-- =========================================================================
-- Every chapter of the courses that have chapters now has 3 subchapters with a full lesson text (the short texts of the earlier sections are
-- replaced), every chapter has a quiz or an assessment, and every quiz has 4 questions, every assessment 5 and every final exam 8.
-- Rows are found by course title + chapter number, never by identity numbers. The question order continues after the existing questions.
-- The lesson text is plain text without angle brackets: the learner page prints it without encoding.
DECLARE @TcTeacher INT, @TcTest INT, @TcQ INT;

-- 7.1. SUBCHAPTERS (lesson text for every subchapter; the missing ones are added)
UPDATE sc SET sc.[SubChapterContent] = N'Python is a high-level, interpreted language created by Guido van Rossum and first released in 1991. It is known for readable code: blocks are marked by indentation instead of braces, and most ideas take fewer lines than in older languages. Python runs web back ends, data analysis, automation scripts, games and machine learning, which is why it is a popular first language. Because it is interpreted, you can type a line and see the result straight away, which makes experimenting and fixing mistakes fast. In this course you will use Python 3 and write small programs from the very first lesson.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Download the latest Python 3 installer from python.org and tick the option that adds Python to your PATH before you click Install. When it finishes, open a terminal and run python --version to confirm the installation; you should see a version number such as Python 3.12. The same terminal starts the interactive shell when you type python, where each line you enter runs immediately. For longer programs, save your code in a file ending in .py and run it with python followed by the file name. A code editor such as VS Code or IDLE makes writing files easier because it colours the code and points out typing mistakes.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Every language starts with Hello, World, and in Python it is one line: print("Hello, World!"). The print function shows whatever you give it on the screen, and text must be wrapped in quotes so Python treats it as a string. Save the line in a file called hello.py and run it with python hello.py. Lines starting with a hash sign are comments, which Python ignores, so use them to explain your code to yourself and to other people. If you see a SyntaxError, check for a missing quote or bracket first; the message tells you the line where Python got confused.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A variable is a name that points to a value, created with a single equals sign, for example age = 20 or name = "Mei". Python has whole numbers (int), decimal numbers (float) and text (str), and it works out the type from the value you assign. Numbers support the usual operators: plus, minus, star for multiply, a slash for division, double slash for whole-number division, and double star for powers. Strings are joined with plus and can be written with single or double quotes. Choose descriptive names in lowercase with underscores, such as total_price, so your code explains itself.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'The input function always returns text, so a number typed by the user must be converted before you do arithmetic with it. Use int() to turn text into a whole number, float() for a decimal number and str() to turn a number back into text. For example, age = int(input("Age: ")) reads a line and stores it as an integer. Converting a value that does not look like a number, such as int("abc"), raises a ValueError, so check your input when it comes from a person. The type() function tells you which type a value currently has, which is handy when a result looks wrong.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'A string is a sequence of characters, so you can count them with len() and pick one with an index; the first character is at position 0 and a negative index counts from the end. Slicing takes a part, so word[1:4] gives the characters at positions 1, 2 and 3. Useful methods include upper(), lower(), strip() to remove spaces at the ends, replace() to swap text, and split() to break a sentence into a list of words. Strings cannot be changed in place, so each method returns a new string that you store in a variable. An f-string such as f"Hello, {name}" is the easiest way to put values into text.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'An if statement runs a block of code only when its condition is true. Add elif to test another condition and else to handle everything that is left. The condition uses comparison operators such as ==, !=, greater than and less than, and you can combine tests with and, or and not. The block belongs to the if because it is indented by four spaces, so the indentation is part of the syntax and must be consistent. For example, a grade program can print Pass when the mark is at least 50 and Fail otherwise. Remember that = assigns a value while == compares two values.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A for loop repeats a block once for every item in a sequence. The most common pattern is for i in range(5), which runs five times with i taking the values 0 to 4; range(1, 6) starts at 1 and stops before 6. You can also loop straight over a list or a string, for example for letter in word. Use break to leave a loop early and continue to skip to the next item. Loops are how programs handle repeated work such as adding up prices, printing a table or checking every item in a list, so look for a loop whenever you catch yourself copying a line.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'A while loop repeats its block for as long as a condition stays true, which suits cases where you do not know in advance how many times to repeat. A typical example keeps asking for a password until the correct one is typed. Something inside the loop must eventually make the condition false, such as increasing a counter, otherwise the program runs forever; press Ctrl+C to stop it if that happens. Choose for when you are walking through a known collection and while when you wait for an event. The else part of a loop and the break statement give you extra control over how the loop ends.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A function is a named block of code that you can run whenever you need it. You define it with the def keyword, a name, brackets and a colon, then indent the body below, for example def greet(): followed by print("Hello"). Calling greet() runs the body. Functions remove repetition, because you write the steps once and reuse them, and they make long programs easier to read by giving each job a clear name. Choose verbs for function names and keep each function focused on one task. Define a function before the line that calls it, since Python reads the file from top to bottom.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Parameters let a function work with different inputs: in def add(a, b) the names a and b receive the values you pass in the call add(2, 3). A function hands a result back with the return keyword, and the caller can store it, as in total = add(2, 3). A function without return gives back None. You can give a parameter a default value, such as def greet(name="friend"), so the argument becomes optional, and you can call with keyword arguments like add(b=3, a=2) to make the call easier to read. Prefer returning a value over printing inside the function, because a returned value can be reused.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Scope decides where a name can be used. A variable created inside a function is local and disappears when the function ends, while a variable created at the top of the file is global and can be read from anywhere. If you assign to a name inside a function, Python makes a new local variable rather than changing the global one, so pass values in and return results out instead of relying on globals. A docstring is a string placed on the first line of a function that explains what it does, and it appears when you call help() on the function. Writing a short docstring for every function is a habit that pays off when you return to your code later.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A list stores several values in order inside square brackets, for example scores = [70, 85, 90]. You reach items by index starting at 0, add one with append(), remove one with remove() or pop(), and find the length with len(). Lists can be changed after they are created, they can hold different types, and for item in scores walks through them. A tuple looks similar but uses round brackets and cannot be changed, which makes it suitable for fixed groups such as a point (3, 4). Slicing works as it does for strings, so scores[:2] gives the first two items. Sorting is done with sort() on the list itself or sorted() for a new list.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A dictionary stores pairs of keys and values inside curly braces, for example student = {"name": "Aina", "age": 19}. You read a value by its key with student["name"], add or change a pair by assigning to a key, and delete one with del. The get() method returns None, or a default you choose, instead of raising a KeyError when the key is missing. Looping with .items() gives you each key and value together, while .keys() and .values() give just one side. Dictionaries are ideal for records, counters and lookups because finding a key is fast no matter how many pairs are stored.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Programs keep data between runs by saving it in files. The with open("notes.txt", "r") as f: statement opens a file and closes it automatically when the block ends. Use read() for the whole text, readlines() for a list of lines, or loop over f to process one line at a time. The mode "w" creates or overwrites a file, "a" appends to the end and "r" only reads. Call f.write("text") to save text, and add a newline character yourself when you want a new line. If the file does not exist, reading raises a FileNotFoundError, so wrap the code in try and except when the file may be missing.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'Every Java program lives inside a class, and execution starts at the main method: public static void main(String[] args). Inside it, System.out.println("Hello, World!") prints a line of text. Save the code in a file whose name matches the public class, such as Hello.java, compile it with javac Hello.java to produce Hello.class, and run it with java Hello. Java is compiled to bytecode that runs on the Java Virtual Machine, which is why the same program works on Windows, macOS and Linux. Every statement ends with a semicolon and blocks are wrapped in curly braces, so a missing one is the most common first error.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Java is statically typed, so you declare the type of every variable, for example int age = 20; or double price = 9.99;. The eight primitive types are byte, short, int and long for whole numbers, float and double for decimals, char for a single character and boolean for true or false. An int holds about two billion at most, so use long for bigger values. Text is not a primitive: String is a class, and its values go in double quotes while a char uses single quotes. Assigning a larger type to a smaller one needs an explicit cast, such as int n = (int) 3.7;, which drops the decimal part. Use final to make a constant.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Java has arithmetic operators plus, minus, star, slash and the remainder operator %, comparison operators such as == and !=, and logical operators && for and, || for or and ! for not. Dividing two ints gives an int, so 7 / 2 is 3; make one side a double to keep the decimals. The ++ and -- operators add or subtract one. To read input from the keyboard, create a Scanner with new Scanner(System.in) and call nextInt(), nextDouble() or nextLine(). Remember to import java.util.Scanner at the top of the file. Combine these to write small programs, such as a calculator that reads two numbers and prints their sum.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A class is a blueprint that describes the data and behaviour of a kind of thing, and an object is one instance of it. Data is stored in fields and behaviour is written as methods. A constructor has the same name as the class and sets up a new object, so new Dog("Rex") creates a Dog and passes the name in. Mark fields private and give them getter and setter methods, which is called encapsulation, so that other code cannot put an object into an invalid state. The keyword this refers to the current object and separates a field from a parameter of the same name. Each object keeps its own copy of the fields.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Inheritance lets a class reuse another class: class Dog extends Animal gives Dog everything in Animal and lets it add or override methods. Use super to call the parent constructor or a parent method. Java allows only one parent class, but a class can implement several interfaces. An interface lists methods that a class promises to provide, without saying how, for example an interface Drawable with a draw method. Abstract classes sit in between: they can hold shared code and also declare methods that subclasses must complete. Use inheritance for an is-a relationship and interfaces for a shared ability.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Polymorphism means one call can behave differently depending on the real type of the object. If Dog and Cat both override speak(), a variable of type Animal that holds either one will run the correct version when you call speak(). This is decided at run time. It lets you write code against a general type, such as a method that accepts a list of Shape objects and calls area() on each, without knowing which shapes will arrive. Mark overriding methods with the @Override annotation so the compiler warns you if the signature does not match. Overloading is different: the same method name with different parameters in one class.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'An exception is an object that signals something went wrong at run time, such as dividing by zero or reading a missing file. Wrap risky code in a try block and handle the problem in a catch block for the exception type you expect, for example catch (ArithmeticException e). The finally block always runs afterwards, whether or not an exception occurred, which makes it the right place to close files or connections. You can write several catch blocks, ordered from the most specific type to the most general. Printing e.getMessage() shows what happened. Catching an exception keeps the program running instead of crashing with a stack trace.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Java splits exceptions into two groups. Checked exceptions, such as IOException, must be either caught or declared with throws in the method signature, and the compiler refuses to build if you do neither. Unchecked exceptions extend RuntimeException, for example NullPointerException and IllegalArgumentException, and usually point to a bug in the code, so the compiler does not force you to handle them. Use the throw keyword to raise an exception yourself, such as throw new IllegalArgumentException("Age cannot be negative"). Choose the group by asking whether a caller can reasonably recover from the problem; if it can, a checked exception documents that fact.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'When the built-in exceptions do not describe your problem, create your own by extending Exception for a checked one or RuntimeException for an unchecked one. A custom class normally offers a constructor that takes a message and passes it to super, for example InsufficientFundsException for a bank account that cannot cover a withdrawal. Throwing it with a clear message makes errors easier to understand and lets callers catch that exact type instead of a general Exception. Keep the names descriptive and end them with the word Exception. You can also wrap a lower-level exception by passing it as the cause, which keeps the original stack trace for debugging.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'The collections framework gives you ready-made containers. An ArrayList keeps items in order and grows automatically; add() appends, get(i) reads, remove() deletes and size() counts. A HashMap stores key and value pairs, so map.put("Aina", 90) saves a mark and map.get("Aina") finds it again in constant time on average. A HashSet keeps unique items only. Program against the interfaces List, Map and Set and choose the implementation when you create the object. Use the enhanced for loop, for (String name : names), to visit every element, and loop over map.entrySet() to see keys and values together.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Generics let a class or method work with a type that you choose, and the compiler checks it for you. Writing List of String, with the type in angle brackets, means the list can only hold strings, so you no longer need casts and a wrong type is caught when you compile instead of when the program runs. You can write your own generic class by declaring a type parameter, such as class Box of T, where T stands for whatever type the user supplies. A bounded type, T extends Comparable, restricts the choice to types that can be compared. Generics are why collections are both flexible and type safe.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Collections.sort(list) orders a list using the natural order of its elements, which for String is alphabetical and for numbers ascending. To sort your own objects, either make the class implement Comparable and define compareTo, or pass a Comparator. A comparator is a rule that compares two items and returns a negative number, zero or a positive number. In modern Java you write it as a lambda, for example students.sort((a, b) -> a.getMark() - b.getMark()), or use Comparator.comparing(Student::getName). Chain thenComparing to break ties and call reversed() for descending order.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'Java reads and writes files with classes from java.io and java.nio.file. The simplest modern approach is Files.readAllLines(Path.of("data.txt")), which returns a list of lines, and Files.writeString to save text. For large files use a BufferedReader inside a try-with-resources statement, which closes the file automatically even if an exception occurs. Most file methods throw IOException, a checked exception, so catch it or declare it with throws. A FileWriter opens a file for writing and overwrites it unless you pass true to append. Always check that the path is correct, because a wrong folder is the usual reason for a file not found error.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A unit test is a small program that checks one piece of code and reports pass or fail. JUnit 5 is the standard framework: mark a method with the @Test annotation and use assertions such as assertEquals(expected, actual) or assertTrue(condition). If an assertion fails, the test is reported with the values it saw. Name tests after the behaviour, for example addReturnsSumOfTwoNumbers, and keep each one independent. @BeforeEach runs set-up code before every test. Run the tests from your IDE or with a build tool such as Maven or Gradle, and re-run them after every change to catch mistakes early.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Test-driven development reverses the usual order: you write a failing test first, then write just enough code to make it pass, then tidy the code while the tests stay green. This red, green, refactor cycle keeps functions small and gives you a safety net for later changes. Start with the simplest case, such as an empty list, then add one more example at a time. Test the edges as well as the normal path: zero, negative numbers, empty text and null. A good test suite runs in seconds, so you can run it after every small edit and know immediately which change broke something.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A CSV file stores a table as plain text with one row per line and values separated by commas. The pandas library reads it in one line: import pandas as pd followed by df = pd.read_csv("sales.csv"). The result is a DataFrame, a table with labelled columns that you can sort, filter and summarise. Pass sep=";" if the file uses another separator, encoding="utf-8" if accented characters look wrong, and parse_dates to turn a column of dates into real date values. If Python cannot find the file, check the working directory or use the full path. Always look at the first rows after loading to confirm the columns came in as expected.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Before any analysis, inspect the table. df.head() shows the first five rows, df.shape gives the number of rows and columns, df.info() lists each column with its type and how many values are present, and df.describe() summarises the numeric columns with count, mean, minimum, quartiles and maximum. df.isna().sum() counts missing values per column. This first look tells you whether numbers were read as text, whether a column is mostly empty and whether the ranges are sensible, for example no negative ages. Write down anything odd, because each issue becomes a cleaning step in the next chapter.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Use square brackets to select a column, df["price"], or several columns with a list, df[["name", "price"]]. A condition inside the brackets filters rows, so df[df["price"] > 100] keeps only the expensive items, and you can combine conditions with & and | when each one is wrapped in brackets. For explicit control use .loc to select by label and .iloc to select by position, such as df.loc[0:4, "name"]. Selections return new objects and leave the original untouched. Learning these three patterns, column, condition and loc, is enough to answer most everyday questions about a table.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'Real data almost always has gaps, which pandas shows as NaN. First measure the problem with df.isna().sum(). Then choose a strategy: dropna() removes rows or columns that contain gaps, fillna(value) replaces them with a number or text, and filling with the mean or median keeps the row while limiting the damage. The right choice depends on the column. A missing customer name might be filled with Unknown, while dropping every row with a missing price could remove half the data. Whatever you decide, record the decision in your notebook so that a reader knows how the numbers were produced.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Columns are sometimes read with the wrong type, for example prices stored as text because of a currency symbol, or dates stored as plain strings. Check the types with df.dtypes. Use astype(float) or pd.to_numeric(column, errors="coerce") to convert numbers, where coerce turns bad entries into NaN instead of stopping with an error, and pd.to_datetime to create real dates. Once dates are real, you can use the .dt accessor to pull out the year, month or weekday. Text columns benefit from str.strip() and str.lower() so that Kuala Lumpur and kuala lumpur are counted as the same city.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Filtering keeps only the rows that match a condition and sorting puts them in a useful order. df[df["city"] == "Penang"] keeps one city, isin(["Penang", "Ipoh"]) matches any value in a list and str.contains finds text inside a column. sort_values("sales", ascending=False) puts the biggest sales first, and you can pass a list of columns to sort by several keys. drop_duplicates() removes repeated rows and reset_index(drop=True) renumbers the rows afterwards. A common pipeline is to filter, sort and then take head(10) to answer a question such as which ten customers spent the most.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'Matplotlib is the standard plotting library in Python: import matplotlib.pyplot as plt. A line chart, plt.plot(x, y), is the right choice for values that change over time, such as monthly sales. A bar chart, plt.bar(labels, values), compares amounts between categories, such as sales by city. Always add a title with plt.title, label both axes with plt.xlabel and plt.ylabel, and finish with plt.show() or plt.savefig to keep the picture. Pandas can draw directly from a DataFrame with df.plot(kind="bar"). Keep the number of colours small and sort bars so that the reader can compare them at a glance.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A histogram groups numbers into ranges called bins and counts how many values fall in each, so plt.hist(df["age"], bins=10) shows how ages are distributed and whether the data is skewed or has gaps. The number of bins changes the picture, so try a few. A box plot summarises the same idea with five numbers: the minimum, the first quartile, the median, the third quartile and the maximum, and it draws dots for outliers beyond the whiskers. Box plots make it easy to compare several groups side by side, for example the salary spread in each department.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'The best chart depends on the question. To show change over time use a line chart. To compare categories use a bar chart, horizontal when the labels are long. To show how values are distributed use a histogram or box plot. To show how two numeric measures relate use a scatter plot. Avoid pie charts with many slices and avoid truncated axes that exaggerate small differences. Remove clutter such as heavy gridlines, give the chart a title that states the finding, for example Sales doubled after May, and make sure the text is large enough to read when the chart is shrunk into a report.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 3 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'The groupby method splits a table into groups, applies a calculation to each group and combines the results. For example df.groupby("city")["sales"].sum() gives total sales per city, and replacing sum with mean, count, min or max changes the summary. Use agg to compute several measures at once, such as agg(["sum", "mean"]), and group by a list of columns to get a finer breakdown, like city and month. The result is indexed by the group names, so call reset_index() when you want an ordinary table again. Grouping is the main tool for answering which category performs best.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A pivot table rearranges grouped data into a grid, with one categorical column down the side and another across the top. In pandas, df.pivot_table(index="city", columns="month", values="sales", aggfunc="sum") shows total sales for every city in every month, and fill_value=0 replaces empty cells. Setting margins=True adds a total row and column. Pivot tables are easier to read than a long list of groups and they can be passed straight to a heatmap or a bar chart. If you only need one dimension, groupby is simpler; reach for a pivot table when you compare two.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Real analysis often needs data from more than one table, such as orders and customers that share a customer_id. pd.merge(orders, customers, on="customer_id") joins them. The how argument decides what happens to rows without a match: inner keeps only matches, left keeps every row from the first table, right keeps the second and outer keeps everything. Check the row count before and after a merge, because duplicate keys can multiply rows without warning. Use pd.concat to stack tables with the same columns, for example one file per month, into a single table.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 4 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'A good analysis begins with a question, not with the data. Write the question in one sentence, for example which product category should the shop promote next month, and decide what evidence would answer it. Identify the audience, because a manager needs a recommendation while a colleague may want the method. List the columns you need, the time period and any filters, and note what the data cannot tell you. A narrow, specific question keeps the work focused and makes it obvious when you have finished. Everything you build afterwards, from cleaning to charts, should help answer that sentence.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Structure the report so that a busy reader gets the answer first. Open with a short summary that states the finding and the recommendation, then show the two or three charts that support it, each with a clear title and a sentence of explanation. Follow with a brief method section covering the data source, the cleaning steps and any assumptions, and finish with limitations and next steps. In a notebook, combine markdown cells and code cells, and rerun everything from the top before you share it to be sure the results are reproducible. Remove experiments that did not lead anywhere.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Presenting is translating numbers into a decision. Start with the conclusion, then walk through the evidence in the order the audience will ask for it. Use one idea per slide or section, show a chart rather than a table of raw numbers, and say what the chart means in plain words. Round numbers sensibly, quote percentages instead of long decimals and be honest about uncertainty, for example a small sample or missing months. Prepare for the question what should we do next and finish with a clear recommendation and the next step. Practise once aloud, because timing problems only show up when you speak.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 5 AND sc.[SubChapterOrder] = 3;
UPDATE sc SET sc.[SubChapterContent] = N'C is a compiled language, so your source code must be translated into a program the computer can run. The GNU Compiler Collection does this with one command: gcc hello.c -o hello creates an executable called hello, and ./hello runs it (hello.exe on Windows). Behind the scenes gcc preprocesses the file, compiles it to object code, assembles it and links it with the standard library. Add -Wall to switch on useful warnings and -g to include debugging information. Read compiler messages from the first one downwards, since a single missing semicolon can cause a chain of later errors, and fix one error at a time before compiling again.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'Every C program starts executing in a function called main. The usual form is int main(void) with a body in curly braces, and the function returns 0 at the end to tell the operating system that the program finished successfully; any other number signals an error. Statements inside the body run from top to bottom and each one ends with a semicolon. Code outside any function can only declare things, it cannot run on its own. Because C does not forgive a missing brace or semicolon, format your code neatly with consistent indentation so that mistakes are easy to see.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Printing and Comments', N'The printf function prints text to the screen. To use it, add the line #include with the stdio.h header at the top of the file, which tells the compiler what printf looks like. A simple call is printf("Hello, World!\n"); where the \n at the end moves to a new line. Format specifiers insert values: %d prints an int, %f a decimal number, %c a character and %s a string, as in printf("Age: %d\n", age). Comments explain the code to humans and are ignored by the compiler: two slashes comment out the rest of a line and slash-star ... star-slash comments out a block.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Declaring Variables', N'A variable reserves a named place in memory, and C requires you to declare its type before you use it, for example int age; or int age = 20;. A declaration without a value leaves garbage in the variable, so initialise variables when you create them. Names may contain letters, digits and underscores, must not start with a digit and are case sensitive, so score and Score are different variables. You can declare several variables of one type in a line, such as int a = 1, b = 2;. Declare a variable close to where you first use it and give it a name that explains its purpose.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Data Types and Sizes', N'C provides char for a single character, short, int and long for whole numbers, and float and double for decimals. The size of each type depends on the machine, and the sizeof operator tells you how many bytes a type or a variable takes, for example sizeof(int) is usually 4. Use unsigned before an integer type when it can never be negative, which doubles the largest positive value. Integer division throws away the remainder, so 7 / 2 gives 3 and you need 7 / 2.0 to get 3.5. A value that is too large for its type wraps around, so choose a type big enough for the numbers you expect.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Constants and Type Casting', N'A constant is a value that must not change. Declare one with the const keyword, as in const double PI = 3.14159;, or define a name with #define, which the preprocessor replaces before compiling. Constants make code easier to read and change, since a value such as the tax rate is written once. Type casting converts a value from one type to another: (double) total / count forces decimal division instead of whole-number division. C also converts types automatically in expressions, usually towards the larger type, and an assignment to a smaller type can lose information, so cast deliberately and explain why in a comment.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'A pointer is a variable that stores the memory address of another variable. Declare one with a star, as in int *p;, and give it an address with the address-of operator: p = &x; makes p point to x. The star used on a pointer, *p, follows the address and reads or changes the value stored there, which is called dereferencing. A pointer that points to nothing should be set to nullptr, and dereferencing it crashes the program, so check before you use a pointer you did not create yourself. Pointers are powerful because they let different parts of a program share data without copying it.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Pointers and Functions', N'By default C++ passes arguments by value, so a function receives a copy and cannot change the caller''s variable. Passing a pointer, as in void addOne(int *n) { *n = *n + 1; }, lets the function modify the original, and you call it with addOne(&x). A reference does the same with simpler syntax: void addOne(int &n) { n++; } is called as addOne(x). Use a const reference, const std::string &name, to avoid copying large objects while promising not to change them. Never return a pointer or reference to a local variable, because it stops existing when the function ends.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Dynamic Memory with new and delete', N'Local variables live on the stack and vanish when their block ends. When you need memory that lasts longer or whose size is only known at run time, allocate it on the heap with new: int *p = new int(5); or int *arr = new int[10];. Every new must be matched with a delete, or delete[] for arrays, otherwise the memory leaks and the program slowly uses more and more. Using memory after deleting it, or deleting it twice, are serious bugs. Modern C++ avoids most of this with smart pointers such as std::unique_ptr, which release the memory automatically when they go out of scope.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Arrays', N'An array stores a fixed number of values of the same type in consecutive memory, for example int marks[5] = {70, 80, 90, 60, 75};. Elements are reached by index starting at 0, so marks[0] is the first and marks[4] the last. Reading or writing outside the range, such as marks[5], is undefined behaviour and is one of the most common causes of crashes. The size of an array is fixed when it is declared and an array does not know its own length when passed to a function, so the length must be passed separately. Use a loop with the index to process every element.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Introducing std::vector', N'The vector container from the standard library is a dynamic array that grows and shrinks as needed. Include the vector header, declare std::vector of int, and add items with push_back(), read the count with size() and access elements with [] or the safer at(), which throws an exception when the index is wrong. pop_back() removes the last element, clear() removes all of them and insert and erase work in the middle at a higher cost. A vector manages its own memory, so there is nothing to delete. In almost every case prefer a vector over a raw array.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Looping and Sorting', N'A range-based for loop, for (int m : marks), visits every element without an index, and adding a reference, for (int &m : marks), lets you change the elements. The algorithm header provides ready-made tools: std::sort(v.begin(), v.end()) sorts in ascending order in O(n log n) time, std::reverse flips the order, std::find searches and std::accumulate in the numeric header adds the values together. Pass a comparison function or a lambda as a third argument to sort in another order. Using the library algorithms is shorter and less error prone than writing your own loops.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'What is Machine Learning?', N'Machine learning is the practice of letting a program find patterns in data instead of writing every rule by hand. A model is shown many examples, adjusts itself to fit them and can then make predictions for new cases, such as whether an email is spam or what a house might sell for. There are three main families. Supervised learning learns from examples that include the correct answer, unsupervised learning looks for structure in data without answers, and reinforcement learning learns by trial and reward. In this course we focus on supervised learning with Python and scikit-learn.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Features and Labels', N'In supervised learning every example has features and a label. The features are the measurable inputs, such as the size, age and location of a house, and the label is the answer you want the model to predict, such as its price. If the label is a number the task is regression, and if it is a category such as spam or not spam the task is classification. Features must be numeric, so text categories are converted into numbers, and features on very different scales are often rescaled. Choosing informative features and cleaning them usually matters more than choosing a fancy algorithm.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Training and Test Sets', N'A model that is judged on the same data it learned from will look perfect even if it has only memorised the examples, which is called overfitting. To measure how well it will work on new data, split the dataset before training: typically 80 percent for training and 20 percent for testing. In scikit-learn, train_test_split(X, y, test_size=0.2, random_state=42) does this, and the random state makes the split repeatable. The model learns only from the training set, and the test set is kept hidden until the end to give an honest score. Never change the model repeatedly to improve the test score.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Fitting a Linear Regression', N'Linear regression finds the straight line, or plane for several features, that best matches the training data. With scikit-learn the steps are always the same: import LinearRegression, create the model with model = LinearRegression(), and train it by calling model.fit(X_train, y_train). After fitting, model.coef_ holds the weight of each feature and model.intercept_ the starting value, so you can read how much each feature changes the prediction. Linear regression is quick, easy to explain and a good baseline before you try something more complex. It works best when the relationship between features and label is roughly linear.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Making Predictions', N'Once a model is fitted, call model.predict(X_test) to get its predicted labels for new rows. The input must have the same columns, in the same order and with the same preparation, as the data used for training, otherwise the numbers are meaningless. Compare the predictions with the real values in y_test to see where the model is wrong, for example by listing the largest errors or plotting predicted against actual values. You can also predict a single new case by passing a list with one row. Remember that a prediction is an estimate, and it is less reliable for inputs far from anything the model has seen.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Measuring Performance', N'To judge a regression model, compare predictions with the true values using error measures from sklearn.metrics. Mean absolute error is the average size of the mistakes in the units of the label, mean squared error punishes large mistakes more, and R squared tells you what fraction of the variation the model explains, where 1 is perfect and 0 is no better than guessing the average. For classification, accuracy is the share of correct answers, and precision and recall describe the types of mistakes. Always calculate the scores on the test set, and compare with a simple baseline to be sure the model adds value.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'Flask is a lightweight web framework for Python. Create a project folder, set up a virtual environment with python -m venv venv and activate it, so the packages for this project stay separate from the rest of your computer. Then run pip install flask to download Flask and its helpers. Confirm the installation with python -c "import flask" and pip show flask, which print an error or the version number. Record the packages you use in a requirements.txt file created with pip freeze so that another person can recreate the same environment. Keep the virtual environment folder out of version control.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A minimal Flask application fits in a few lines. Import Flask, create the app with app = Flask(__name__), and define a function that returns the text for a page, marked with the decorator @app.route("/"). When a browser asks for the home page, Flask calls that function and sends its return value back as the response. Save the code as app.py and start it with flask run, then open http://127.0.0.1:5000 in a browser to see your page. The decorator is what connects the URL to the function, and a function can return plain text, HTML or a rendered template.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Debug Mode and Project Layout', N'While you develop, run flask run --debug. Debug mode reloads the server automatically whenever you save a file and shows an interactive error page with the full traceback, which saves a lot of time. Never leave debug mode on in a public site, because the error page can reveal your code. As the project grows, keep it organised: app.py for the application, a templates folder for HTML files, a static folder for CSS, images and JavaScript, and a requirements.txt file. Flask looks for the templates and static folders by these exact names, so spelling matters.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Defining Routes', N'A route links a URL to a Python function. The decorator @app.route("/about") makes the function below it answer requests for /about. Parts of the URL can be variables: @app.route("/user/name") with the name in angle brackets passes the value to the function as an argument, and a converter such as int ensures the part is a number. By default a route only answers GET requests, so a page that receives a form needs methods=["GET", "POST"], and request.method tells you which one arrived. Use url_for with the function name to build links instead of typing paths, so links keep working if a URL changes.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Jinja Templates', N'Returning long HTML strings from a function gets messy, so Flask uses the Jinja template engine. Save an HTML file in the templates folder and display it with render_template("home.html", name="Aina"). Inside the template, double curly braces insert a value, for example Hello name, and percent tags give you logic: an if tag shows content conditionally and a for tag repeats it for every item in a list. Jinja escapes values automatically, which protects the page from injected scripts. Filters change the output, such as name | upper. Keep calculations in Python and keep the templates focused on layout.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Template Inheritance', N'Most pages in a site share the same header, menu and footer. With template inheritance you write that layout once in a base.html file and mark the changing parts with block tags, for example a block called content. Every other template starts with an extends tag naming base.html and then fills in its blocks, so only the unique part of each page is written. Changing the navigation menu then means editing a single file. You can also split small pieces, such as a product card, into separate files and pull them in with an include tag. This keeps a growing site consistent and easy to maintain.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 2;
UPDATE sc SET sc.[SubChapterContent] = N'In Python a function is an object like any other. You can store it in a variable, put it in a list, pass it as an argument and return it from another function. For example, after def shout(text): return text.upper(), the line speak = shout makes speak another name for the same function. Functions that accept or return other functions are called higher-order functions, and map(), filter() and sorted(key=...) are everyday examples. A function defined inside another function can use the outer function''s variables even after the outer one has finished, which is called a closure. These ideas are the foundation of decorators.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 1 AND sc.[SubChapterOrder] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Writing a Decorator', N'A decorator is a function that takes a function and returns a new function that wraps it, adding behaviour before or after the original runs. Typical uses are logging, timing and checking permissions. You write an inner function called wrapper that accepts any arguments with *args and **kwargs, calls the original and returns its result, then return wrapper. Applying it with @my_decorator above a function definition is shorthand for func = my_decorator(func). Use functools.wraps on the wrapper so that the decorated function keeps its original name and docstring, which helps with debugging and documentation.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Decorators with Arguments', N'Sometimes a decorator needs its own settings, such as @repeat(3) to run a function three times. Because the decorator line is evaluated first, repeat(3) must itself return the real decorator. That gives three nested levels: the outer function receives the setting, the middle function receives the function being decorated and the inner wrapper receives the call arguments. It looks complicated at first, but it follows one rule: each layer returns the next layer down. Test the pattern with a small example such as a retry decorator, and keep functools.wraps on the innermost function.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 1;
UPDATE sc SET sc.[SubChapterContent] = N'A normal function runs to completion and returns one value. A function that contains yield is a generator: calling it does not run the body, it returns a generator object that produces values one at a time as you ask for them. Each time the loop needs the next value the function resumes right after the last yield, with all its local variables intact, and it stops when the function ends. This is called lazy evaluation, and it lets you work with huge or endless sequences without holding them in memory. For example, a generator that yields the numbers 1 to a million uses almost no memory.', sc.[DateUpdate] = GETDATE() FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = sc.[ChapterId]
WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 2 AND sc.[SubChapterOrder] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Building an Iterator', N'An iterable is anything you can loop over, and an iterator is the object that remembers the position. An iterator class implements two methods: __iter__ returns the iterator itself and __next__ returns the next value or raises StopIteration when there are no more. The for loop calls iter() on the object once and then calls next() until StopIteration is raised. You can try this by hand with iter() and next() on a list. Writing a class gives you full control, for example a countdown that remembers its current number, but a generator function usually does the same job in far fewer lines.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Generator Expressions', N'A generator expression looks like a list comprehension but uses round brackets: squares = (n * n for n in range(1000000)). Instead of building the whole list it creates values on demand, so it uses very little memory. You can pass one straight into a function that consumes a sequence, such as sum(n * n for n in range(10)) or max(len(w) for w in words). The trade-off is that a generator can be used only once and has no length or indexing. Choose a list when you need to reuse the values and a generator when you only loop over them once.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Lists and Order', N'A List keeps its elements in the order they were added and allows duplicates. ArrayList is backed by an array, so reading by index is fast, while LinkedList is faster for adding and removing at the ends. Common methods are add(), get(index), set(index, value), remove(), contains(), indexOf() and size(). List.of(...) creates a list that cannot be changed, which is a good default for fixed data. Use Collections.sort or list.sort to order the items, and loop with the enhanced for statement. Choose a list whenever the position of an element matters or the same value may appear more than once.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'Sets and Uniqueness', N'A Set stores each value at most once, so adding a duplicate has no effect. HashSet is the fastest and has no guaranteed order, LinkedHashSet remembers insertion order and TreeSet keeps the elements sorted. Methods include add(), contains(), remove() and size(), and add returns false when the value was already there. Sets are ideal for removing duplicates from a list, by creating new HashSet from the list, and for checking membership quickly. The set operations addAll for union, retainAll for intersection and removeAll for difference let you compare groups, for example students in two classes.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Maps and Lookups', N'A Map connects keys to values and each key appears only once. HashMap offers fast lookup with no order, LinkedHashMap keeps insertion order and TreeMap sorts by key. Use put(key, value) to store, get(key) to read, containsKey() to test and remove() to delete. getOrDefault(key, 0) avoids a null result for a missing key, and merge or computeIfAbsent make counting and grouping short, such as counting how often each word appears. To loop, use entrySet(), which gives each key and value together. Keys should be immutable, because changing a key after it is stored makes the value hard to find.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, N'Creating a Stream', N'A stream is a pipeline that processes a sequence of elements without changing the original data. You create one from a collection with list.stream(), from values with Stream.of(...), from an array with Arrays.stream(array) or from numbers with IntStream.range(1, 10). A stream has three parts: a source, zero or more intermediate operations such as filter and map, and one terminal operation such as collect, count or forEach. Nothing runs until the terminal operation is called, and a stream can be used only once. Streams let you describe what you want instead of writing the loops yourself.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 2, N'filter and map', N'The filter operation keeps the elements that match a condition, and map transforms each element into something else. For a list of names, names.stream().filter(n -> n.startsWith("A")).map(String::toUpperCase) keeps the names beginning with A and converts them to capitals. The condition and the transformation are lambda expressions or method references. Other useful operations are sorted, distinct and limit, and mapToInt to work with numbers so that you can call sum, min, max and average. Each operation returns a new stream, so the steps can be chained into a readable pipeline that reads from top to bottom.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -7, GETDATE()), 3, N'Collecting Results', N'A stream is usually turned back into a collection or a single value. The collect method with Collectors.toList() gathers the elements into a list (toList() on the stream does the same in newer versions), toSet() removes duplicates and joining(", ") builds one string. Collectors.groupingBy groups elements into a map, for example students by grade, and counting or summingInt can be added to summarise each group. Terminal operations such as count, reduce, anyMatch, allMatch and findFirst return a single answer. Use streams for clear data processing and fall back to a simple loop when a pipeline would be harder to read.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 2;

-- 7.2. QUIZZES FOR THE CHAPTERS THAT HAD NO QUIZ OR ASSESSMENT
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'Arrays and Vectors Quiz', N'Check how arrays and vectors store collections of data.', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'ML Foundations Quiz', N'Check the basic ideas of supervised machine learning.', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'Model Training Quiz', N'Check how a model is trained, used and measured.', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'Lists, Sets and Maps Quiz', N'Check which collection to use and how it behaves.', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, GETDATE()), N'Streams Quiz', N'Check how a stream pipeline filters and transforms data.', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 2;

-- 7.3. QUESTIONS (multiple choice 3 options; quizzes 2 marks each, assessments 2 / 3 / 5 marks, exams 5 marks each)

-- Python Programming Fundamentals, chapter 2
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which function converts the text "42" into the whole number 42?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'int()', 1, 1, @TcQ), (N'str()', 0, 2, @TcQ), (N'type()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which of these is a valid variable name in Python?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'2nd_place', 0, 1, @TcQ), (N'total_price', 1, 2, @TcQ), (N'my-score', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What type does the value "hello" have?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'int', 0, 1, @TcQ), (N'bool', 0, 2, @TcQ), (N'str', 1, 3, @TcQ);

-- Python Programming Fundamentals, chapter 3
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 3);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does the keyword break do inside a loop?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'It leaves the loop immediately', 1, 1, @TcQ), (N'It skips to the next item', 0, 2, @TcQ), (N'It restarts the loop', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'How many times does for i in range(4) run its body?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3 times', 0, 1, @TcQ), (N'4 times', 1, 2, @TcQ), (N'5 times', 0, 3, @TcQ);

-- Python Programming Fundamentals, chapter 5
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 5);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does len([4, 8, 15]) return?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3', 1, 1, @TcQ), (N'2', 0, 2, @TcQ), (N'15', 0, 3, @TcQ);

-- Java Programming Masterclass, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which statement prints a line of text in Java?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'System.out.println("Hi");', 1, 1, @TcQ), (N'print("Hi");', 0, 2, @TcQ), (N'console.log("Hi");', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does 7 / 2 give when both numbers are ints?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3.5', 0, 1, @TcQ), (N'3', 1, 2, @TcQ), (N'4', 0, 3, @TcQ);

-- Java Programming Masterclass, chapter 3
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 3);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which keyword in a method signature declares an exception the method can throw?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'throws', 1, 1, @TcQ), (N'raise', 0, 2, @TcQ), (N'except', 0, 3, @TcQ);

-- Java Programming Masterclass, chapter 5
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 5);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which JUnit assertion checks that two values are equal?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'assertEquals', 1, 1, @TcQ), (N'assertNull', 0, 2, @TcQ), (N'assertThrows', 0, 3, @TcQ);

-- Data Analysis with Python, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which DataFrame method shows the first five rows?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'head()', 1, 1, @TcQ), (N'tail()', 0, 2, @TcQ), (N'info()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which attribute gives the number of rows and columns of a DataFrame df?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'df.columns', 0, 1, @TcQ), (N'df.shape', 1, 2, @TcQ), (N'df.index', 0, 3, @TcQ);

-- Data Analysis with Python, chapter 3
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 3);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which chart is best for comparing amounts between categories?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Bar chart', 1, 1, @TcQ), (N'Scatter plot', 0, 2, @TcQ), (N'Box plot', 0, 3, @TcQ);

-- Data Analysis with Python, chapter 5
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 5);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Where should the main finding appear in a report?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'At the start, in a short summary', 1, 1, @TcQ), (N'Only in the last paragraph', 0, 2, @TcQ), (N'Hidden in an appendix', 0, 3, @TcQ);

-- C Programming Essentials, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which command compiles hello.c with gcc into a program called hello?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'gcc hello.c -o hello', 1, 1, @TcQ), (N'run hello.c', 0, 2, @TcQ), (N'compile hello', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does return 0; at the end of main usually mean?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The program crashed', 0, 1, @TcQ), (N'The program finished successfully', 1, 2, @TcQ), (N'The program must run again', 0, 3, @TcQ);

-- C++ Algorithms & Data Structures, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does nullptr mean?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A pointer that points to nothing', 1, 1, @TcQ), (N'A pointer to the first variable', 0, 2, @TcQ), (N'A pointer to a string', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which keyword allocates memory on the heap in C++?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'int', 0, 1, @TcQ), (N'new', 1, 2, @TcQ), (N'this', 0, 3, @TcQ);

-- C++ Algorithms & Data Structures, chapter 2
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the index of the first element of an array?', 'MCQ', 2, 1, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'0', 1, 1, @TcQ), (N'1', 0, 2, @TcQ), (N'-1', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which vector method adds an element at the end?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'add', 0, 1, @TcQ), (N'push_back', 1, 2, @TcQ), (N'append', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What happens if you read marks[10] in an array of 5 elements?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The compiler always reports an error', 0, 1, @TcQ), (N'It safely returns 0', 0, 2, @TcQ), (N'Undefined behaviour', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which header provides std::sort?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'algorithm', 1, 1, @TcQ), (N'string', 0, 2, @TcQ), (N'iostream', 0, 3, @TcQ);

-- Machine Learning with Python, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the goal of supervised learning?', 'MCQ', 2, 1, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Learn from examples that have known answers', 1, 1, @TcQ), (N'Group data without any answers', 0, 2, @TcQ), (N'Learn only from rewards', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A model predicts the price of a house. What is this task called?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Classification', 0, 1, @TcQ), (N'Regression', 1, 2, @TcQ), (N'Clustering', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why do we keep a test set?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'To make training faster', 0, 1, @TcQ), (N'To add more features', 0, 2, @TcQ), (N'To measure how the model performs on new data', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is it called when a model memorises the training data and performs badly on new data?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Overfitting', 1, 1, @TcQ), (N'Scaling', 0, 2, @TcQ), (N'Labelling', 0, 3, @TcQ);

-- Machine Learning with Python, chapter 2
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Machine Learning with Python' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method trains a scikit-learn model?', 'MCQ', 2, 1, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'fit()', 1, 1, @TcQ), (N'predict()', 0, 2, @TcQ), (N'score()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method returns predictions for new data?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'fit()', 0, 1, @TcQ), (N'predict()', 1, 2, @TcQ), (N'train()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which metric gives the average size of the errors in the units of the label?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'R squared', 0, 1, @TcQ), (N'Confusion matrix', 0, 2, @TcQ), (N'Mean absolute error', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which function splits data into training and test sets?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'train_test_split', 1, 1, @TcQ), (N'split_data', 0, 2, @TcQ), (N'fit_split', 0, 3, @TcQ);

-- Web Apps with Python and Flask, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Where does Flask look for HTML templates by default?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'In a folder named templates', 1, 1, @TcQ), (N'In a folder named static', 0, 2, @TcQ), (N'In the same folder as app.py', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does flask run --debug do?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Deploys the app to the internet', 0, 1, @TcQ), (N'Reloads the server when files change and shows detailed errors', 1, 2, @TcQ), (N'Deletes the cache', 0, 3, @TcQ);

-- Advanced Python Patterns, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does functools.wraps preserve on a decorated function?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Its name and docstring', 1, 1, @TcQ), (N'Its speed', 0, 2, @TcQ), (N'Its arguments only', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which parameters let a wrapper accept any arguments?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'self and cls', 0, 1, @TcQ), (N'*args and **kwargs', 1, 2, @TcQ), (N'x and y', 0, 3, @TcQ);

-- Java Collections and Streams, chapter 1
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which collection allows duplicate values and keeps insertion order?', 'MCQ', 2, 1, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'List', 1, 1, @TcQ), (N'Set', 0, 2, @TcQ), (N'Map', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method adds a key and a value to a HashMap?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'add', 0, 1, @TcQ), (N'put', 1, 2, @TcQ), (N'insert', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What happens when you add a duplicate value to a HashSet?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'An exception is thrown', 0, 1, @TcQ), (N'The value is stored twice', 0, 2, @TcQ), (N'The set is unchanged', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which class keeps its elements sorted?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'TreeSet', 1, 1, @TcQ), (N'HashSet', 0, 2, @TcQ), (N'ArrayList', 0, 3, @TcQ);

-- Java Collections and Streams, chapter 2
SET @TcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Collections and Streams' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which stream operation keeps only the elements that match a condition?', 'MCQ', 2, 1, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'filter', 1, 1, @TcQ), (N'map', 0, 2, @TcQ), (N'sorted', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which stream operation transforms each element into something else?', 'MCQ', 2, 2, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'filter', 0, 1, @TcQ), (N'map', 1, 2, @TcQ), (N'limit', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'When does a stream pipeline start to run?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'When the stream is created', 0, 1, @TcQ), (N'When the first filter is added', 0, 2, @TcQ), (N'When a terminal operation is called', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method turns a stream back into a collection?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, @TcTest, NULL, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'collect', 1, 1, @TcQ), (N'build', 0, 2, @TcQ), (N'stream', 0, 3, @TcQ);

-- Python Programming Fundamentals, chapter 1
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 1);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which symbol starts a comment in Python?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'#', 1, 1, @TcQ), (N'//', 0, 2, @TcQ), (N'--', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A Python file normally ends with the ____ extension.', 'FillBlank', 3, 5, N'.py, py', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Python Programming Fundamentals, chapter 4
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 4);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does a function return if it has no return statement?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'None', 1, 1, @TcQ), (N'0', 0, 2, @TcQ), (N'An empty string', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The values you pass into a function when you call it are called ____.', 'FillBlank', 3, 5, N'arguments, argument, args', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Java Programming Masterclass, chapter 2
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a constructor?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A special method that sets up a new object', 1, 1, @TcQ), (N'A method that deletes an object', 0, 2, @TcQ), (N'A variable shared by all classes', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ keyword refers to the current object.', 'FillBlank', 3, 4, N'this', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A class uses the ____ keyword to inherit from a parent class.', 'FillBlank', 3, 5, N'extends', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Java Programming Masterclass, chapter 4
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 4);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which class stores a resizable list of items?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'ArrayList', 1, 1, @TcQ), (N'HashSet', 0, 2, @TcQ), (N'Scanner', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ method of a List returns the number of elements.', 'FillBlank', 3, 5, N'size, size()', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Data Analysis with Python, chapter 2
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which expression counts the missing values in each column of df?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'df.isna().sum()', 1, 1, @TcQ), (N'df.describe()', 0, 2, @TcQ), (N'df.sort_values()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ method replaces missing values with a given value.', 'FillBlank', 3, 4, N'fillna, fillna()', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that fills the missing values in the column age of df with the mean age.', 'Coding', 5, 5, NULL, N'df["age"] = df["age"].fillna(df["age"].mean())', N'2 marks for fillna, 2 marks for the mean of the column, 1 mark for assigning the result back', @TcTeacher, NULL, @TcTest, NULL);

-- Data Analysis with Python, chapter 4
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 4);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does df.groupby("city")["sales"].sum() return?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Total sales for each city', 1, 1, @TcQ), (N'The sales of the first city', 0, 2, @TcQ), (N'A sorted list of cities', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ method creates a pivot table from a DataFrame.', 'FillBlank', 3, 5, N'pivot_table, pivot_table()', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- C Programming Essentials, chapter 2
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which format specifier prints an int with printf?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'%d', 1, 1, @TcQ), (N'%f', 0, 2, @TcQ), (N'%s', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ type holds a decimal number with double precision in C.', 'FillBlank', 3, 4, N'double', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A variable declared with the ____ keyword cannot be changed.', 'FillBlank', 3, 5, N'const', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Web Apps with Python and Flask, chapter 2
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which HTTP method does a Flask route answer by default?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'GET', 1, 1, @TcQ), (N'POST', 0, 2, @TcQ), (N'DELETE', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ function turns a template file into an HTML response.', 'FillBlank', 3, 4, N'render_template, render_template()', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ object in Flask holds the data sent by the browser.', 'FillBlank', 3, 5, N'request', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Advanced Python Patterns, chapter 2
SET @TcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 2);
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does a generator function return when it is called?', 'MCQ', 2, 3, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A generator object', 1, 1, @TcQ), (N'A list of all the values', 0, 2, @TcQ), (N'None', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which exception ends the iteration of an iterator?', 'MCQ', 2, 4, NULL, NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'ValueError', 0, 1, @TcQ), (N'StopIteration', 1, 2, @TcQ), (N'EndOfLoop', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A generator expression is written with ____ brackets instead of square brackets.', 'FillBlank', 3, 5, N'round, parentheses', NULL, NULL, @TcTeacher, NULL, @TcTest, NULL);

-- Final exam: Python Programming Fundamentals
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which data type stores pairs of keys and values?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Dictionary', 1, 1, @TcQ), (N'List', 0, 2, @TcQ), (N'Tuple', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the output of print(10 % 3)?', 'MCQ', 5, 6, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3', 0, 1, @TcQ), (N'1', 1, 2, @TcQ), (N'3.33', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ keyword stops a loop early.', 'FillBlank', 5, 7, N'break', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a function is_even(n) that returns True when n is even.', 'Coding', 5, 8, NULL, N'def is_even(n):
    return n % 2 == 0', N'2 marks for def and the parameter, 2 marks for the % 2 test, 1 mark for returning the result', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Java Programming Masterclass
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which keyword is used to handle an exception?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'catch', 1, 1, @TcQ), (N'handle', 0, 2, @TcQ), (N'rescue', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which collection keeps unique values only?', 'MCQ', 5, 6, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'ArrayList', 0, 1, @TcQ), (N'HashSet', 1, 2, @TcQ), (N'LinkedList', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Every Java program starts running in the ____ method.', 'FillBlank', 5, 7, N'main', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a method sum(int a, int b) that returns the sum of the two numbers.', 'Coding', 5, 8, NULL, N'public static int sum(int a, int b) {
    return a + b;
}', N'2 marks for the method signature, 2 marks for adding the numbers, 1 mark for returning the result', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Data Analysis with Python
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which function reads a CSV file into a DataFrame?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'pd.read_csv', 1, 1, @TcQ), (N'pd.open_csv', 0, 2, @TcQ), (N'pd.load_file', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which chart type shows how values are distributed?', 'MCQ', 5, 6, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Pie chart', 0, 1, @TcQ), (N'Histogram', 1, 2, @TcQ), (N'Line chart', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ attribute holds the column names of a DataFrame.', 'FillBlank', 5, 7, N'columns, df.columns', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that selects the rows of df where the column sales is greater than 100.', 'Coding', 5, 8, NULL, N'df[df["sales"] > 100]', N'3 marks for the condition, 2 marks for using it to select the rows', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: C Programming Essentials
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which keyword declares a variable that cannot change?', 'MCQ', 5, 2, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'const', 1, 1, @TcQ), (N'fixed', 0, 2, @TcQ), (N'final', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which function reads formatted input from the keyboard in C?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'input', 0, 1, @TcQ), (N'scanf', 1, 2, @TcQ), (N'cin', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the result of 7 / 2 when both numbers are ints in C?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'3.5', 0, 1, @TcQ), (N'4', 0, 2, @TcQ), (N'3', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Every C statement ends with a ____.', 'FillBlank', 5, 5, N'semicolon, ;', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ operator returns the size of a type in bytes.', 'FillBlank', 5, 6, N'sizeof', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a C program that prints the number 42 with printf.', 'Coding', 5, 7, NULL, N'#include <stdio.h>

int main(void) {
    printf("%d\n", 42);
    return 0;
}', N'2 marks for the include and main, 2 marks for the printf call, 1 mark for the correct output', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Declare an int variable called count with the value 10 and print it.', 'Coding', 5, 8, NULL, N'int count = 10;
printf("%d\n", count);', N'2 marks for the declaration, 1 mark for the value, 2 marks for printf with %d', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: C++ Algorithms & Data Structures
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What must be paired with every new[] to avoid a memory leak?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'delete[]', 1, 1, @TcQ), (N'free()', 0, 2, @TcQ), (N'close()', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the time complexity of std::sort on n elements?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'O(n)', 0, 1, @TcQ), (N'O(n log n)', 1, 2, @TcQ), (N'O(1)', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does int &r = x; create?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A copy of x', 0, 1, @TcQ), (N'A pointer to x', 0, 2, @TcQ), (N'A reference to x', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A pointer that points to nothing should be set to ____.', 'FillBlank', 5, 6, N'nullptr', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a function swapValues(int &a, int &b) that swaps two integers.', 'Coding', 5, 7, NULL, N'void swapValues(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
}', N'2 marks for the reference parameters, 2 marks for the swap, 1 mark for using a temporary variable', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Create a std::vector of int called nums with the values 3, 1 and 2, then sort it.', 'Coding', 5, 8, NULL, N'std::vector<int> nums = {3, 1, 2};
std::sort(nums.begin(), nums.end());', N'2 marks for the vector, 3 marks for sorting with begin() and end()', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Machine Learning with Python
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which library provides LinearRegression?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'scikit-learn', 1, 1, @TcQ), (N'matplotlib', 0, 2, @TcQ), (N'flask', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is predicting a category such as spam or not spam called?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Regression', 0, 1, @TcQ), (N'Classification', 1, 2, @TcQ), (N'Scaling', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What share of the data is usually kept for the test set?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'About 90 percent', 0, 1, @TcQ), (N'None of it', 0, 2, @TcQ), (N'About 20 percent', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ method trains a scikit-learn model on the training data.', 'FillBlank', 5, 6, N'fit, fit()', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that splits X and y into training and test sets, keeping 20 percent for testing.', 'Coding', 5, 7, NULL, N'from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)', N'2 marks for the import, 2 marks for test_size=0.2, 1 mark for the four returned variables', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that trains a LinearRegression model on X_train and y_train, then predicts for X_test.', 'Coding', 5, 8, NULL, N'from sklearn.linear_model import LinearRegression
model = LinearRegression()
model.fit(X_train, y_train)
predictions = model.predict(X_test)', N'1 mark for creating the model, 2 marks for fit, 2 marks for predict', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Web Apps with Python and Flask
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which command starts a Flask application?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'flask run', 1, 1, @TcQ), (N'flask build', 0, 2, @TcQ), (N'flask open', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does {{ name }} do in a Jinja template?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Creates a new variable called name', 0, 1, @TcQ), (N'Displays the value of name', 1, 2, @TcQ), (N'Comments out name', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which argument lets a route accept form submissions?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'accept="form"', 0, 1, @TcQ), (N'allow="POST"', 0, 2, @TcQ), (N'methods=["GET", "POST"]', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Templates share a common layout by using template ____.', 'FillBlank', 5, 6, N'inheritance', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a Flask route /about that returns the text About us.', 'Coding', 5, 7, NULL, N'@app.route("/about")
def about():
    return "About us"', N'2 marks for the route decorator, 2 marks for the function, 1 mark for returning the text', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a Flask route /user/name that takes a name from the URL and returns a greeting.', 'Coding', 5, 8, NULL, N'@app.route("/user/<name>")
def user(name):
    return f"Hello, {name}!"', N'2 marks for the variable part of the URL, 1 mark for the parameter, 2 marks for returning a greeting', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Advanced Python Patterns
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does @decorator above a function do?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Replaces the function with decorator(function)', 1, 1, @TcQ), (N'Deletes the function', 0, 2, @TcQ), (N'Runs the function twice', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method returns the next value of an iterator?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'__iter__', 0, 1, @TcQ), (N'__next__', 1, 2, @TcQ), (N'__init__', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is an advantage of a generator over a list?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'It can be indexed', 0, 1, @TcQ), (N'It can be reused forever', 0, 2, @TcQ), (N'It produces values lazily and uses less memory', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A function defined inside another function that remembers its variables is called a ____.', 'FillBlank', 5, 6, N'closure', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a decorator log_call that prints Calling before running the function it wraps.', 'Coding', 5, 7, NULL, N'def log_call(func):
    def wrapper(*args, **kwargs):
        print("Calling")
        return func(*args, **kwargs)
    return wrapper', N'2 marks for the wrapper, 1 mark for the print, 2 marks for calling and returning the original function', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a generator evens(limit) that yields the even numbers from 2 up to limit.', 'Coding', 5, 8, NULL, N'def evens(limit):
    for n in range(2, limit + 1, 2):
        yield n', N'2 marks for the loop, 1 mark for the range, 2 marks for yield', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Java Collections and Streams
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which collection is best for counting how often each word appears?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Map', 1, 1, @TcQ), (N'Set', 0, 2, @TcQ), (N'Array', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which List implementation is backed by a resizable array?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'LinkedList', 0, 1, @TcQ), (N'ArrayList', 1, 2, @TcQ), (N'TreeSet', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does map(String::toUpperCase) do in a stream?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Removes elements', 0, 1, @TcQ), (N'Sorts the elements', 0, 2, @TcQ), (N'Converts each element to capitals', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A stream can be used only ____.', 'FillBlank', 5, 6, N'once', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that creates a List of String called names containing Aina and Ben, using List.of.', 'Coding', 5, 7, NULL, N'List<String> names = List.of("Aina", "Ben");', N'2 marks for the List declaration, 3 marks for List.of with both names', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a stream expression that counts the numbers greater than 10 in a List of Integer called nums.', 'Coding', 5, 8, NULL, N'long total = nums.stream().filter(n -> n > 10).count();', N'1 mark for stream(), 2 marks for the filter, 2 marks for count()', @TcTeacher, NULL, NULL, @TcTest);

-- Final exam: Databases with Python
SET @TcTest = (SELECT e.[ExamId] FROM [dbo].[Exam] e WHERE e.[CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python'));
SET @TcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which SQL command adds a new row to a table?', 'MCQ', 5, 3, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'INSERT INTO', 1, 1, @TcQ), (N'ADD ROW', 0, 2, @TcQ), (N'CREATE ROW', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which Python module provides a built-in SQLite database?', 'MCQ', 5, 4, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'pandas', 0, 1, @TcQ), (N'sqlite3', 1, 2, @TcQ), (N'flask', 0, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the purpose of a parameterised query?', 'MCQ', 5, 5, NULL, NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
SET @TcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'To make the table larger', 0, 1, @TcQ), (N'To sort the rows', 0, 2, @TcQ), (N'To prevent SQL injection', 1, 3, @TcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The SQL clause ORDER ____ sorts the rows of a result.', 'FillBlank', 5, 6, N'BY, by', NULL, NULL, @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a SQL query that selects the name column of the students table where age is greater than 18.', 'Coding', 5, 7, NULL, N'SELECT name FROM students WHERE age > 18;', N'1 mark for SELECT name, 1 mark for FROM students, 3 marks for the WHERE condition', @TcTeacher, NULL, NULL, @TcTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write Python code that connects to an SQLite file called school.db and then closes the connection.', 'Coding', 5, 8, NULL, N'import sqlite3
conn = sqlite3.connect("school.db")
conn.close()', N'1 mark for the import, 2 marks for connect, 2 marks for close', @TcTeacher, NULL, NULL, @TcTest);

PRINT 'Subchapters, quizzes, assessments and exams completed.';

-- =========================================================================
-- 8. TEACHER QUALIFICATIONS (shown under Qualifications & Credentials on the teacher's My Account page)
-- =========================================================================
-- The document files are in media/uploads/qualifications/, stored the same way as a document uploaded at registration.

UPDATE [dbo].[Teacher] SET [QualificationName] = N'MSc in Computer Science', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_bryan_yeong.pdf' WHERE [Email] = N'bryanyeong@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'BSc (Hons) in Software Engineering', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_sarah_lim.pdf' WHERE [Email] = N'sarahlim@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'Certified Java Programmer', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_nina_tan.pdf' WHERE [Email] = N'ninatan@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'Diploma in Information Technology', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_alvin_chong.pdf' WHERE [Email] = N'alvinchong@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'Certified Python Developer', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_priya_nair.pdf' WHERE [Email] = N'priyanair@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'BSc in Data Science', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_daniel_wong.pdf' WHERE [Email] = N'danielwong@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'MSc in Cybersecurity', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_mei_ling_tan.pdf' WHERE [Email] = N'meilingtan@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'BEng in Computer Engineering', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_hafiz_rahman.pdf' WHERE [Email] = N'hafizrahman@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'Postgraduate Certificate in Education', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_grace_lee.pdf' WHERE [Email] = N'gracelee@edu.com.my';
UPDATE [dbo].[Teacher] SET [QualificationName] = N'BSc in Information Systems', [QualificationDocument] = N'~/media/uploads/qualifications/qual_seed_omar_farouk.pdf' WHERE [Email] = N'omarfarouk@edu.com.my';

PRINT 'Teacher qualifications added.';

-- =========================================================================
-- 9. SUBMISSIONS TO MARK FOR EVERY TEACHER WHO HAS A COURSE WITH TESTS
-- =========================================================================
-- Every teacher with courses gets learner submissions waiting for grading: some untouched ("Not graded"), some marked by a teaching
-- assistant and waiting for the teacher (GradingProgress 'Reviewed' with notes and provisional marks, TA_Id set) and some the teacher has started
-- (GradingProgress 'in_progress'). Hafiz Rahman's and Mei Ling Tan's courses had no tests, so each gets a final exam first.
-- A multiple-choice answer is the id of the option the learner chose; fill-in-the-blank and coding answers are text, marked 'pending'.
-- Rows are found by course title, chapter number and e-mail address, never by identity numbers.
DECLARE @PsTest INT, @PsTeacher INT, @PsQ INT;

-- 9.1. FINAL EXAMS FOR THE COURSES THAT HAD NONE
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Final Course Examination', N'Final exam for C Pointers Workshop.', 50, 60, 1, 0, c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Pointers Workshop'));
SET @PsTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Pointers Workshop');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does the * operator do when it is applied to a pointer?', 'MCQ', 5, 1, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Reads or writes the value at the address', 1, 1, @PsQ), (N'Returns the address of a variable', 0, 2, @PsQ), (N'Declares a new array', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which function allocates memory on the heap in C?', 'MCQ', 5, 2, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'new', 0, 1, @PsQ), (N'malloc', 1, 2, @PsQ), (N'create', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What should you do when you have finished with memory from malloc?', 'MCQ', 5, 3, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Call delete on it', 0, 1, @PsQ), (N'Nothing, it is released automatically', 0, 2, @PsQ), (N'Call free on it', 1, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does int *p = NULL; mean?', 'MCQ', 5, 4, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'p points to nothing', 1, 1, @PsQ), (N'p points to the value 0', 0, 2, @PsQ), (N'p is an array of zero ints', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ operator gives the address of a variable.', 'FillBlank', 5, 5, N'&, ampersand', NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A pointer that is used after its memory was freed is called a ____ pointer.', 'FillBlank', 5, 6, N'dangling', NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write code that declares an int x with the value 7 and a pointer p that points to x.', 'Coding', 5, 7, NULL, N'int x = 7;
int *p = &x;', N'2 marks for x, 2 marks for the pointer declaration, 1 mark for taking the address', @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a C function void addOne(int *n) that adds 1 to the integer n points to.', 'Coding', 5, 8, NULL, N'void addOne(int *n) {
    *n = *n + 1;
}', N'2 marks for the signature, 2 marks for dereferencing n, 1 mark for adding one', @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Exam] ([DateCreation], [DateUpdate], [ExamTitle], [ExamDescription], [PassMark], [TimeLimitMinutes], [StrictSyntax], [AllowLibraries], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Final Course Examination', N'Final exam for Cybersecurity Basics with Python.', 50, 60, 0, 1, c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python'));
SET @PsTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python');
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why should passwords be stored as hashes instead of plain text?', 'MCQ', 5, 1, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A leaked database does not reveal the passwords', 1, 1, @PsQ), (N'Hashes are shorter to type', 0, 2, @PsQ), (N'Hashes can easily be turned back into the password', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is SQL injection?', 'MCQ', 5, 2, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Copying a database to a backup', 0, 1, @PsQ), (N'Inserting malicious SQL through user input', 1, 2, @PsQ), (N'Speeding up a query with an index', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which is the best defence against SQL injection?', 'MCQ', 5, 3, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Longer passwords', 0, 1, @PsQ), (N'Hiding the table names', 0, 2, @PsQ), (N'Parameterised queries', 1, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does HTTPS add to HTTP?', 'MCQ', 5, 4, NULL, NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
SET @PsQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Encryption of the traffic', 1, 1, @PsQ), (N'Faster downloads', 0, 2, @PsQ), (N'Larger pages', 0, 3, @PsQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A ____ is a one-way function that turns text into a fixed-length string.', 'FillBlank', 5, 5, N'hash', NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Checking that a user is who they say they are is called ____.', 'FillBlank', 5, 6, N'authentication', NULL, NULL, @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write Python code that hashes the text password with SHA-256 using hashlib and prints the hex digest.', 'Coding', 5, 7, NULL, N'import hashlib
print(hashlib.sha256(b"password").hexdigest())', N'1 mark for the import, 2 marks for sha256, 2 marks for hexdigest and print', @PsTeacher, NULL, NULL, @PsTest);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a Python function is_strong(pw) that returns True when pw has at least 8 characters.', 'Coding', 5, 8, NULL, N'def is_strong(pw):
    return len(pw) >= 8', N'2 marks for the function, 2 marks for the length test, 1 mark for returning the result', @PsTeacher, NULL, NULL, @PsTest);

-- 9.2. ENROLMENTS (a learner who submitted must be enrolled in the course)
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'ethanlim2002@gmail.com' AND c.[CourseTitle] = N'Python Programming Fundamentals' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'gavinooi@gmail.com' AND c.[CourseTitle] = N'Python Programming Fundamentals' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'lucasng99@gmail.com' AND c.[CourseTitle] = N'Python Programming Fundamentals' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'hana.yusof@gmail.com' AND c.[CourseTitle] = N'Java Programming Masterclass' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'iman.hakim@gmail.com' AND c.[CourseTitle] = N'Java Programming Masterclass' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'jasonkoh@gmail.com' AND c.[CourseTitle] = N'Data Analysis with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'kavitha.raj@gmail.com' AND c.[CourseTitle] = N'Data Analysis with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'aisyah.rahman@gmail.com' AND c.[CourseTitle] = N'C Programming Essentials' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'bentan88@gmail.com' AND c.[CourseTitle] = N'C Programming Essentials' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'chenwei.lee@gmail.com' AND c.[CourseTitle] = N'C++ Algorithms & Data Structures' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'divya.menon@gmail.com' AND c.[CourseTitle] = N'Machine Learning with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'ethanlim2002@gmail.com' AND c.[CourseTitle] = N'Web Apps with Python and Flask' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'farah.aziz@gmail.com' AND c.[CourseTitle] = N'Web Apps with Python and Flask' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'gavinooi@gmail.com' AND c.[CourseTitle] = N'Advanced Python Patterns' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'hana.yusof@gmail.com' AND c.[CourseTitle] = N'Advanced Python Patterns' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'iman.hakim@gmail.com' AND c.[CourseTitle] = N'Java Collections and Streams' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'jasonkoh@gmail.com' AND c.[CourseTitle] = N'Databases with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'kavitha.raj@gmail.com' AND c.[CourseTitle] = N'Databases with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'lucasng99@gmail.com' AND c.[CourseTitle] = N'C Pointers Workshop' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'aisyah.rahman@gmail.com' AND c.[CourseTitle] = N'C Pointers Workshop' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'bentan88@gmail.com' AND c.[CourseTitle] = N'Cybersecurity Basics with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], 1, DATEADD(DAY, -14, GETDATE()) FROM [dbo].[Learner] l CROSS JOIN [dbo].[Course] c WHERE l.[Email] = N'chenwei.lee@gmail.com' AND c.[CourseTitle] = N'Cybersecurity Basics with Python' AND NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);

-- 9.3. SUBMISSIONS: the attempts and their grading progress first, then the learners' answers and the provisional marks for all of them at once
DECLARE @PsFirst INT = (SELECT ISNULL(MAX([AttemptId]), 0) FROM [dbo].[Attempt]);

-- Python Programming Fundamentals | asm ch1 | ethanlim2002@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 1);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -30, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'ethanlim2002@gmail.com'), NULL, @PsTest, NULL);

-- Python Programming Fundamentals | asm ch4 | gavinooi@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Python Programming Fundamentals' AND ch.[ChapterNum] = 4);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -26, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'gavinooi@gmail.com'), NULL, @PsTest, NULL);

-- Python Programming Fundamentals | exam | lucasng99@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Python Programming Fundamentals'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -22, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'lucasng99@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Marks follow the marking guide. The loop answer is correct, the function answer is missing the return.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'ta1234@gmail.com'), SCOPE_IDENTITY());

-- Java Programming Masterclass | asm ch2 | hana.yusof@gmail.com | draft
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Java Programming Masterclass' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -20, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'hana.yusof@gmail.com'), NULL, @PsTest, NULL);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'Checking the Dog class against the model answer before confirming.', (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'), NULL, SCOPE_IDENTITY());

-- Java Programming Masterclass | exam | iman.hakim@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Programming Masterclass'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -18, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'iman.hakim@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Good attempt overall. Please double-check the isEven method marks.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'marcus.ta@edu.com.my'), SCOPE_IDENTITY());

-- Data Analysis with Python | asm ch2 | jasonkoh@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Data Analysis with Python' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -16, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'jasonkoh@gmail.com'), NULL, @PsTest, NULL);

-- Data Analysis with Python | exam | kavitha.raj@gmail.com | pending
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Data Analysis with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -14, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'kavitha.raj@gmail.com'), NULL, NULL, @PsTest);

-- C Programming Essentials | asm ch2 | aisyah.rahman@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Programming Essentials' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -28, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'aisyah.rahman@gmail.com'), NULL, @PsTest, NULL);

-- C Programming Essentials | exam | bentan88@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Programming Essentials'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -24, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'bentan88@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Syntax is strict in this exam: the printf answer is missing a semicolon, so I gave partial marks.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'ta1234@gmail.com'), SCOPE_IDENTITY());

-- C++ Algorithms & Data Structures | exam | chenwei.lee@gmail.com | pending
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C++ Algorithms & Data Structures'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -12, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'chenwei.lee@gmail.com'), NULL, NULL, @PsTest);

-- Machine Learning with Python | exam | divya.menon@gmail.com | draft
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -10, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'divya.menon@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'Compare the train_test_split answer with the marking guide.', (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Machine Learning with Python'), NULL, SCOPE_IDENTITY());

-- Web Apps with Python and Flask | asm ch2 | ethanlim2002@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Web Apps with Python and Flask' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -8, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'ethanlim2002@gmail.com'), NULL, @PsTest, NULL);

-- Web Apps with Python and Flask | exam | farah.aziz@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Web Apps with Python and Flask'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -6, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'farah.aziz@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Routes are right. The /user route returns text but not a greeting, so partial marks.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'marcus.ta@edu.com.my'), SCOPE_IDENTITY());

-- Advanced Python Patterns | asm ch2 | gavinooi@gmail.com | pending
SET @PsTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Advanced Python Patterns' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -40, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'gavinooi@gmail.com'), NULL, @PsTest, NULL);

-- Advanced Python Patterns | exam | hana.yusof@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Advanced Python Patterns'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -36, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'hana.yusof@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'The decorator works; the generator answer yields the wrong range.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'ta1234@gmail.com'), SCOPE_IDENTITY());

-- Java Collections and Streams | exam | iman.hakim@gmail.com | draft
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -32, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'iman.hakim@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'Streams answers need a second look.', (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Java Collections and Streams'), NULL, SCOPE_IDENTITY());

-- Databases with Python | exam | jasonkoh@gmail.com | pending
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -34, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'jasonkoh@gmail.com'), NULL, NULL, @PsTest);

-- Databases with Python | exam | kavitha.raj@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -4, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'kavitha.raj@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'The SQL query is correct. The sqlite3 answer forgets to close the connection.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'marcus.ta@edu.com.my'), SCOPE_IDENTITY());

-- C Pointers Workshop | exam | lucasng99@gmail.com | pending
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Pointers Workshop'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -3, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'lucasng99@gmail.com'), NULL, NULL, @PsTest);

-- C Pointers Workshop | exam | aisyah.rahman@gmail.com | ta
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Pointers Workshop'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -2, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'aisyah.rahman@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('Reviewed', N'Pointer declaration is right; addOne does not dereference n.', NULL, (SELECT [TA_Id] FROM [dbo].[Teaching_Assistant] WHERE [Email] = N'ta1234@gmail.com'), SCOPE_IDENTITY());

-- Cybersecurity Basics with Python | exam | bentan88@gmail.com | pending
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -5, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'bentan88@gmail.com'), NULL, NULL, @PsTest);

-- Cybersecurity Basics with Python | exam | chenwei.lee@gmail.com | draft
SET @PsTest = (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = (SELECT [CourseId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python'));
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId]) VALUES (DATEADD(HOUR, -1, GETDATE()), 'completed', (SELECT [LearnerId] FROM [dbo].[Learner] WHERE [Email] = N'chenwei.lee@gmail.com'), NULL, NULL, @PsTest);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('in_progress', N'Checking the hashing answer.', (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python'), NULL, SCOPE_IDENTITY());

-- The answers of every new attempt, one row per question. A multiple-choice answer is the id of the option picked (mostly the right one),
-- a fill-in-the-blank answer is the first accepted answer or 'not sure', a coding answer is the model answer or its first part.
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT a.[AttemptId], q.[QuestionId], CASE q.[QuestionType] WHEN 'MCQ' THEN CAST((SELECT TOP 1 o.[MCQ_OptionId] FROM [dbo].[MCQ_Option] o WHERE o.[QuestionId] = q.[QuestionId] AND o.[IsCorrect] = IIF((q.[QuestionOrder] + a.[AttemptId]) % 3 = 0, 0, 1) ORDER BY o.[OptionOrder]) AS NVARCHAR(MAX)) WHEN 'FillBlank' THEN IIF((q.[QuestionOrder] + a.[AttemptId]) % 2 = 0, LTRIM(RTRIM(LEFT(q.[AcceptedAnswers] + ',', CHARINDEX(',', q.[AcceptedAnswers] + ',') - 1))), N'not sure') ELSE IIF((q.[QuestionOrder] + a.[AttemptId]) % 2 = 0, q.[ModelAnswer], LEFT(q.[ModelAnswer], CEILING(LEN(q.[ModelAnswer]) * 0.6))) END, 'pending', 0, N''
FROM [dbo].[Attempt] a INNER JOIN [dbo].[Question] q ON (q.[ExamId] = a.[ExamId] OR q.[QuizId] = a.[QuizId] OR q.[AssessmentId] = a.[AssessmentId]) WHERE a.[AttemptId] > @PsFirst;
-- the teaching assistants' provisional marks (80 percent) and the teacher's started marks (50 percent) on the written answers
UPDATE aa SET aa.[ObtainedScore] = FLOOR(q.[QuestionScore] * 0.8), aa.[TeacherComment] = N'Provisional mark from the teaching assistant.' FROM [dbo].[AttemptAnswer] aa INNER JOIN [dbo].[Question] q ON q.[QuestionId] = aa.[QuestionId] INNER JOIN [dbo].[GradingProgress] g ON g.[AttemptId] = aa.[AttemptId] WHERE aa.[AttemptId] > @PsFirst AND g.[ProgressStatus] = 'Reviewed' AND q.[QuestionType] IN ('FillBlank', 'Coding');
UPDATE aa SET aa.[ObtainedScore] = FLOOR(q.[QuestionScore] * 0.5), aa.[TeacherComment] = N'Needs a closer look.' FROM [dbo].[AttemptAnswer] aa INNER JOIN [dbo].[Question] q ON q.[QuestionId] = aa.[QuestionId] INNER JOIN [dbo].[GradingProgress] g ON g.[AttemptId] = aa.[AttemptId] WHERE aa.[AttemptId] > @PsFirst AND g.[ProgressStatus] = 'in_progress' AND q.[QuestionType] IN ('FillBlank', 'Coding');

PRINT 'Submissions to mark added for every teacher with tests.';

-- =========================================================================
-- 10. ANSWERS FOR THE QUESTIONS THAT WERE ADDED AFTER AN ATTEMPT WAS MADE
-- =========================================================================
-- Section 7 gave every quiz, assessment and exam more questions, but the learner attempts made before that only hold answers for the earlier
-- ones, so viewing such an attempt showed the new questions unanswered. This adds the missing answers of every submitted attempt:
--   * an attempt that is already graded (it has a Result) gets answers that fit its other answers: all correct when its earlier answers were all
--     correct, otherwise mostly correct, with the marks and the verdict of each answer; the Result (total, average, grade) is then worked out
--     again from the answers, so the attempt, its answers and its result agree;
--   * an attempt that is still waiting for marking gets 'pending' answers worth 0 marks, like the answers it already has.
-- A multiple-choice answer is the id of the chosen option; fill-in-the-blank and coding answers are text.
CREATE TABLE #TcMissing ([AttemptId] INT NOT NULL, [QuestionId] INT NOT NULL, PRIMARY KEY ([AttemptId], [QuestionId]));

INSERT INTO #TcMissing ([AttemptId], [QuestionId])
SELECT a.[AttemptId], q.[QuestionId]
FROM [dbo].[Attempt] a
INNER JOIN [dbo].[Question] q ON (q.[ExamId] = a.[ExamId] OR q.[QuizId] = a.[QuizId] OR q.[AssessmentId] = a.[AssessmentId])
WHERE a.[AttemptStatus] IN ('completed', 'graded')
  AND NOT EXISTS (SELECT 1 FROM [dbo].[AttemptAnswer] x WHERE x.[AttemptId] = a.[AttemptId] AND x.[QuestionId] = q.[QuestionId]);

-- an attempt whose earlier answers were all marked correct (and that has at least one answer)
SELECT a.[AttemptId] INTO #TcAllCorrect FROM [dbo].[Attempt] a
WHERE EXISTS (SELECT 1 FROM [dbo].[AttemptAnswer] x WHERE x.[AttemptId] = a.[AttemptId])
  AND NOT EXISTS (SELECT 1 FROM [dbo].[AttemptAnswer] x WHERE x.[AttemptId] = a.[AttemptId] AND x.[IsCorrect] <> 'correct');

INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT a.[AttemptId], q.[QuestionId],
       CASE q.[QuestionType]
            WHEN 'MCQ' THEN CAST((SELECT TOP 1 o.[MCQ_OptionId] FROM [dbo].[MCQ_Option] o WHERE o.[QuestionId] = q.[QuestionId] AND o.[IsCorrect] = IIF(f.[Wrong] = 1, 0, 1) ORDER BY o.[OptionOrder]) AS NVARCHAR(MAX))
            WHEN 'FillBlank' THEN IIF(f.[Wrong] = 1, N'not sure', LTRIM(RTRIM(LEFT(q.[AcceptedAnswers] + ',', CHARINDEX(',', q.[AcceptedAnswers] + ',') - 1))))
            ELSE IIF(f.[Wrong] = 1, LEFT(q.[ModelAnswer], CEILING(LEN(q.[ModelAnswer]) * 0.6)), q.[ModelAnswer]) END,
       IIF(f.[Graded] = 0, 'pending', IIF(f.[Wrong] = 0, 'correct', IIF(q.[QuestionType] = 'Coding', 'partial', 'incorrect'))),
       IIF(f.[Graded] = 0, 0, IIF(f.[Wrong] = 0, q.[QuestionScore], IIF(q.[QuestionType] = 'Coding', FLOOR(q.[QuestionScore] * 0.5), 0))),
       IIF(f.[Graded] = 1 AND f.[Wrong] = 0, N'Well done', N'')
FROM #TcMissing m
INNER JOIN [dbo].[Attempt] a ON a.[AttemptId] = m.[AttemptId]
INNER JOIN [dbo].[Question] q ON q.[QuestionId] = m.[QuestionId]
CROSS APPLY (SELECT IIF(EXISTS (SELECT 1 FROM [dbo].[Result] r WHERE r.[AttemptId] = a.[AttemptId]), 1, 0) AS [Graded]) g
CROSS APPLY (SELECT CASE WHEN g.[Graded] = 0 THEN IIF((q.[QuestionOrder] + a.[AttemptId]) % 3 = 0, 1, 0)
                         WHEN EXISTS (SELECT 1 FROM #TcAllCorrect c WHERE c.[AttemptId] = a.[AttemptId]) THEN 0
                         ELSE IIF((q.[QuestionOrder] + a.[AttemptId]) % 4 = 0, 1, 0) END AS [Wrong], g.[Graded] AS [Graded]) f;

-- the Result of every graded attempt that got answers is worked out again from its answers
UPDATE r SET r.[TotalScore] = t.[Total], r.[Average] = t.[Percent],
       r.[Grade] = IIF(t.[Percent] >= 80, 'A', IIF(t.[Percent] >= 70, 'B', IIF(t.[Percent] >= 60, 'C', IIF(t.[Percent] >= 50, 'D', 'F'))))
FROM [dbo].[Result] r
INNER JOIN (SELECT s.[AttemptId], s.[Total], IIF(s.[Max] > 0, ROUND(s.[Total] * 100.0 / s.[Max], 1), 0) AS [Percent]
            FROM (SELECT a.[AttemptId],
                         (SELECT ISNULL(SUM(aa.[ObtainedScore]), 0) FROM [dbo].[AttemptAnswer] aa WHERE aa.[AttemptId] = a.[AttemptId]) AS [Total],
                         (SELECT ISNULL(SUM(q.[QuestionScore]), 0) FROM [dbo].[Question] q WHERE q.[ExamId] = a.[ExamId] OR q.[QuizId] = a.[QuizId] OR q.[AssessmentId] = a.[AssessmentId]) AS [Max]
                  FROM [dbo].[Attempt] a WHERE a.[AttemptId] IN (SELECT [AttemptId] FROM #TcMissing)) s) t ON t.[AttemptId] = r.[AttemptId];

DROP TABLE #TcAllCorrect;
DROP TABLE #TcMissing;

PRINT 'Missing answers of earlier attempts added.';

-- =========================================================================
-- 11. FULL CONTENT AND LEARNER HISTORY FOR DATABASES WITH PYTHON, C POINTERS WORKSHOP AND CYBERSECURITY BASICS WITH PYTHON
-- =========================================================================
-- These three courses only had a final exam. Each now has 5 chapters of 3 lessons, a quiz or an assessment in every chapter (quizzes have 4
-- questions, assessments 5), media (image, MP4 video or PDF in media/uploads/<courseId>/) on every chapter, on two lessons of each chapter and on
-- every quiz and assessment, and a history: learners at different points of the course, with their graded quiz and assessment attempts, a few
-- submissions that wait for the teacher or a teaching assistant, graded final exams, certificates and reviews.
-- Rows are found by course title, chapter number and e-mail address, never by identity numbers. Passwords of the learners are unchanged.
DECLARE @NcFirst INT = (SELECT ISNULL(MAX([AttemptId]), 0) FROM [dbo].[Attempt]);

-- 11.1. CHAPTERS, LESSONS, QUIZZES AND ASSESSMENTS
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'Introduction to Databases', N'Learn what a database is, how data is stored in tables, and why Python programs use databases.', N'3 hours', N'media/uploads/10/chapter-01-introduction-to-databases.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Databases with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'What is a Database?', N'A database is an organised collection of data that a program can store, search and change reliably. Unlike a plain text file, a database manages many users at once, protects data from being half written when something fails and finds records quickly even when there are millions of them. Shops keep their products and orders in databases, schools keep student records and apps keep user accounts. A piece of software called a database management system, or DBMS, looks after the files and answers requests. SQLite, MySQL and PostgreSQL are well-known examples.', N'media/uploads/10/lesson-01-1-what-is-a-database.mp4', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'Tables, Rows and Columns', N'A relational database stores data in tables. A table is like a spreadsheet: each column has a name and a type, such as name text or age integer, and each row is one record, for example one student. Every table should have a primary key, a column whose value is different in every row, so that each record can be identified exactly. Tables are given plural names such as students or orders. Thinking in tables first, before writing any code, makes it much easier to see what data you need and how the pieces connect.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Why Use Python with a Database?', N'Python can talk to a database, send it commands written in SQL and use the answers inside a program. This lets you build programs whose data survives after they close: a to-do list that remembers tasks, a shop that stores orders or a report that reads yesterday''s sales. Python includes the sqlite3 module, so you can create a complete database in a single file without installing a server. In this course you will use sqlite3 to practise every idea, and the same ideas carry over to larger systems.', N'media/uploads/10/lesson-01-3-why-use-python-with-a-database.pdf', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Database Basics Quiz', N'Check your understanding of tables, rows, columns and keys.', N'media/uploads/10/quiz-database-basics-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'SQL Fundamentals', N'Read, add, change and remove data with the core SQL commands.', N'4 hours', N'media/uploads/10/chapter-02-sql-fundamentals.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Databases with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'SELECT and WHERE', N'The SELECT command reads data from a table. SELECT name, age FROM students returns two columns for every row, and SELECT star returns all of them. A WHERE clause keeps only the rows that match a condition, such as WHERE age is greater than 18 or WHERE city equals ''Penang''. Conditions can be combined with AND, OR and NOT, and text is written in single quotes. SQL words are not case sensitive, but writing the keywords in capitals makes queries easier to read. End a statement with a semicolon.', N'media/uploads/10/lesson-02-1-select-and-where.png', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'INSERT, UPDATE and DELETE', N'INSERT INTO adds a new row: INSERT INTO students (name, age) VALUES (''Aina'', 19). UPDATE changes existing rows: UPDATE students SET age = 20 WHERE name = ''Aina''. DELETE FROM removes rows: DELETE FROM students WHERE name = ''Aina''. Always include a WHERE clause with UPDATE and DELETE, because without one the command affects every row in the table. Test a risky change by running a SELECT with the same WHERE clause first, so you can see which rows it will touch.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Sorting and Filtering Results', N'ORDER BY sorts the result: ORDER BY age DESC puts the oldest first, and ORDER BY name ASC sorts alphabetically. LIMIT keeps only the first rows, so ORDER BY marks DESC LIMIT 3 gives the top three. DISTINCT removes repeated values, and the aggregate functions COUNT, SUM, AVG, MIN and MAX summarise many rows in one answer. GROUP BY calculates them for each group, for example the average mark for each class. Together these let a single query answer questions that would take a loop in a program.', N'media/uploads/10/lesson-02-3-sorting-and-filtering-results.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'SQL Queries Assessment', N'Write and explain basic SQL queries.', N'media/uploads/10/assessment-sql-queries-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Python and SQLite', N'Connect to a database from Python, run queries and pass values to them safely.', N'3 hours', N'media/uploads/10/chapter-03-python-and-sqlite.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Databases with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'Connecting with sqlite3', N'Import the sqlite3 module and call sqlite3.connect with a file name, for example conn = sqlite3.connect("school.db"). If the file does not exist, SQLite creates it. The connection object represents the database; from it you create a cursor with conn.cursor(), which is what runs commands and fetches results. When your changes are finished, call conn.commit() to save them and conn.close() to release the file. Using the connection in a with block commits or rolls back automatically.', N'media/uploads/10/lesson-03-1-connecting-with-sqlite3.pdf', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'Running Queries from Python', N'A cursor runs SQL with cur.execute("SELECT name, age FROM students"). To read the answer, call cur.fetchall() for a list of tuples, cur.fetchone() for the next row or loop directly over the cursor. Each row is a tuple, so row[0] is the first selected column. Statements that change data, such as INSERT, only become permanent after conn.commit(). Setting conn.row_factory = sqlite3.Row lets you read columns by name, which makes the code easier to understand.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Parameterised Queries', N'Never build a query by joining strings with user input, because a user can type SQL that changes the meaning of your command; this attack is called SQL injection. Instead, put a question mark where each value goes and pass the values separately: cur.execute("SELECT * FROM students WHERE name = ?", (name,)). The database treats the values only as data, never as commands. Use parameters for every value that comes from outside the program, including numbers, and keep the SQL text itself fixed.', N'media/uploads/10/lesson-03-3-parameterised-queries.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'sqlite3 Quiz', N'Check how Python connects to and queries a database.', N'media/uploads/10/quiz-sqlite3-quiz.png', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 4, N'Designing Tables', N'Plan tables that connect through keys and avoid repeated data.', N'3 hours', N'media/uploads/10/chapter-04-designing-tables.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Databases with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'Primary and Foreign Keys', N'A primary key uniquely identifies each row, and many tables use an integer id that the database fills in automatically. A foreign key is a column that holds the primary key of a row in another table, linking the two. For example an orders table has a customer_id column that points to the customers table. The database can refuse a foreign key value that does not exist, which stops orders belonging to customers who were never created. Keys are what make a set of tables behave as one connected system.', N'media/uploads/10/lesson-04-1-primary-and-foreign-keys.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'Relationships and Joins', N'Tables relate in three ways: one to one, one to many and many to many. One customer with many orders is one to many, stored with a foreign key on the many side. A JOIN combines related rows in a single result: SELECT customers.name, orders.total FROM customers JOIN orders ON orders.customer_id = customers.id. An INNER JOIN keeps only rows that match on both sides, while a LEFT JOIN keeps every row from the first table and fills gaps with NULL. Many to many relationships need a third linking table.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Normalisation Basics', N'Normalisation means arranging data so that each fact is stored once. If a customer''s address is copied into every order, changing it means editing many rows and mistakes creep in. Instead, store the address in the customers table and refer to it by key. As a guide, each column should hold a single value, each table should describe one kind of thing and every non-key column should depend on the key. A well-normalised design is smaller, easier to update and gives fewer surprises.', N'media/uploads/10/lesson-04-3-normalisation-basics.jpg', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Joins Assessment', N'Design related tables and combine them with joins.', N'media/uploads/10/assessment-joins-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 5, N'A Small Database Project', N'Combine everything to plan, build and report on a small database application.', N'3 hours', N'media/uploads/10/chapter-05-a-small-database-project.png', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Databases with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 1, N'Planning the Project', N'Start a project by writing down what the program must remember and what questions it must answer. For a small library system you might need books, members and loans. Sketch each table with its columns, mark the primary keys and draw a line for every foreign key. Then list the main actions, such as add a book, lend a book and list overdue loans, and think about which SQL each one needs. A few minutes of planning avoids rebuilding the tables after the code is written.', N'media/uploads/10/lesson-05-1-planning-the-project.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 2, N'Building the Data Layer', N'Keep all the SQL in one place, such as a module with a function for each action: add_book, lend_book, list_loans. Each function opens a connection, runs a parameterised query, commits if it changed data and closes the connection. The rest of the program calls these functions and never sees SQL, which makes the code easier to test and change. Create the tables once with CREATE TABLE IF NOT EXISTS, so the program can start on an empty file and set itself up.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), 3, N'Reporting and Backup', N'Reports turn rows into answers: a query with GROUP BY can show loans per member, and ORDER BY with LIMIT can show the most borrowed books. Format the results clearly, with headings and aligned columns, before printing or saving them to a file. A database file is a single file, so a backup can be as simple as copying it, or using the connection''s backup method while the program runs. Practise restoring from a backup at least once, because a backup you have never tested is only a hope.', N'media/uploads/10/lesson-05-3-reporting-and-backup.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Project Review Quiz', N'Check how a small database project is planned and built.', N'media/uploads/10/quiz-project-review-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'Memory and Addresses', N'See how a program''s memory is organised and how every variable has an address.', N'2 hours', N'media/uploads/11/chapter-01-memory-and-addresses.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'How Memory Is Organised', N'A computer''s memory is a long row of numbered bytes. Every variable your program creates lives in some of those bytes, and the number of its first byte is its address. A char takes one byte, an int usually four and a double eight. The compiler decides where each local variable goes, in a region called the stack, while memory you request while the program runs comes from the heap. Understanding that variables are just labelled places in memory is the first step to understanding pointers.', N'media/uploads/11/lesson-01-1-how-memory-is-organised.mp4', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Addresses and the Address-of Operator', N'The address-of operator, written with an ampersand, gives the address of a variable: if x is an int, then the expression ampersand x is where x is stored. Printing it with printf and the %p format shows the address as a hexadecimal number, such as 0x7ffd5c3a. Addresses change from one run to another, so never rely on a particular value. What matters is that the same variable always has the same address while it exists, and two different variables have different addresses.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Pointer Variables', N'A pointer is a variable that stores an address. You declare one with a star: int *p; means p can hold the address of an int. Assign it with p = ampersand x; and then p points to x. The star used on a pointer, written *p, follows the address and reads or changes the value stored there, which is called dereferencing. Writing *p = 10; changes x to 10. Always give a pointer a value before you use it; an unset pointer holds garbage and dereferencing it can crash the program.', N'media/uploads/11/lesson-01-3-pointer-variables.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Memory Basics Quiz', N'Check how memory, addresses and pointer variables work.', N'media/uploads/11/quiz-memory-basics-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Pointer Arithmetic and Arrays', N'Use pointers to move through arrays and strings.', N'3 hours', N'media/uploads/11/chapter-02-pointer-arithmetic-and-arrays.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'Pointers and Arrays', N'In C an array name is closely tied to a pointer: in most expressions the name of an array stands for the address of its first element. If marks is an int array, then marks and the address of marks[0] are the same, and *marks is the same value as marks[0]. When you pass an array to a function, what the function receives is really a pointer to the first element, which is why it cannot tell how long the array is and the length must be passed as well.', N'media/uploads/11/lesson-02-1-pointers-and-arrays.png', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Pointer Arithmetic', N'Adding a number to a pointer moves it by that many elements, not that many bytes. If p points to an int and ints take four bytes, then p + 1 is the address four bytes further on, which is the next int. This means *(p + i) is the same as p[i]. You can also subtract two pointers into the same array to find how many elements lie between them, and compare pointers with the usual operators. Never move a pointer outside its array, as the result is undefined.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Strings as Character Arrays', N'A C string is an array of char that ends with the null character, written as a backslash and a zero. A string literal such as "hello" occupies six bytes: five letters and the terminator. A function such as strlen walks a char pointer until it reaches that terminator. Because a string is just an array, you can step through it with a pointer: while (*p) { p++; }. Remember that a string literal cannot be modified; copy it into an array first if you need to change it.', N'media/uploads/11/lesson-02-3-strings-as-character-arrays.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Pointer Arithmetic Assessment', N'Use pointers to work with arrays and strings.', N'media/uploads/11/assessment-pointer-arithmetic-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Pointers and Functions', N'Pass data to functions by address and learn what is safe to return.', N'2 hours', N'media/uploads/11/chapter-03-pointers-and-functions.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'Passing by Pointer', N'C passes arguments by value, so a function normally changes only its own copy. To let a function change the caller''s variable, pass its address and have the function dereference it. void addOne(int *n) { *n = *n + 1; } called as addOne(ampersand x) really changes x. The same idea lets a function return several results through pointer parameters, and avoids copying large structures. Mark the parameter const, for example const int *p, when the function only reads the data.', N'media/uploads/11/lesson-03-1-passing-by-pointer.pdf', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Returning Pointers Safely', N'A function must never return the address of one of its own local variables. Local variables live on the stack and disappear when the function ends, so the returned pointer would refer to memory that is no longer yours; this is called a dangling pointer. Safe choices are to return a pointer into memory the caller supplied, to return a pointer to a static or global variable, or to return memory from malloc that the caller will later free. Document who owns the memory.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Function Pointers', N'A function also has an address, and a function pointer stores it. A pointer to a function that takes two ints and returns an int is declared as int (*op)(int, int);. Assign it with op = add; and call it with op(2, 3). Function pointers let you pass behaviour to another function, such as the comparison function that qsort calls to decide the order, or build a table of commands that a program looks up. The brackets around *op matter: without them the line declares a function.', N'media/uploads/11/lesson-03-3-function-pointers.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Functions and Pointers Quiz', N'Check how pointers work with functions.', N'media/uploads/11/quiz-functions-and-pointers-quiz.png', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 4, N'Dynamic Memory', N'Request memory while the program runs and give it back correctly.', N'3 hours', N'media/uploads/11/chapter-04-dynamic-memory.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'malloc and free', N'The function malloc asks the heap for a number of bytes and returns a pointer to them, or NULL if there is not enough memory. To allocate room for ten ints write int *a = malloc(10 * sizeof(int)); and check that a is not NULL before using it. When you have finished, call free(a); to return the memory. Every successful malloc needs exactly one free. Calloc works like malloc but also sets the memory to zero. Set a pointer to NULL after freeing it so it cannot be used by mistake.', N'media/uploads/11/lesson-04-1-malloc-and-free.pdf', 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Resizing with realloc', N'When a block of memory is too small, realloc asks for a bigger or smaller one: a = realloc(a, 20 * sizeof(int)); The contents are kept, but the block may move, so always use the pointer that realloc returns. If realloc fails it returns NULL and the old block is still allocated, so store the result in a temporary pointer first and assign it to a only after checking it. Growing a block by doubling its size each time keeps the number of copies small.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Finding Leaks', N'A memory leak happens when memory is allocated and the program loses its only pointer to it without calling free. A short program hides the problem because the operating system reclaims everything when it ends, but a long-running program slowly uses more and more memory. Tools such as valgrind run your program and report every block that was never freed, with the line that allocated it. Get into the habit of writing the free at the same moment you write the malloc, and keep ownership of every block clear.', N'media/uploads/11/lesson-04-3-finding-leaks.jpg', 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Dynamic Memory Assessment', N'Allocate, resize and release memory correctly.', N'media/uploads/11/assessment-dynamic-memory-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 5, N'Pointer Pitfalls and Debugging', N'Recognise the classic pointer bugs and find them with debugging tools.', N'2 hours', N'media/uploads/11/chapter-05-pointer-pitfalls-and-debugging.png', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'C Pointers Workshop';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 1, N'Null and Dangling Pointers', N'Two bugs cause most pointer crashes. A null pointer holds NULL, meaning it points to nothing, and dereferencing it stops the program with a segmentation fault; check pointers that might be NULL before using them. A dangling pointer still holds an address, but the memory was freed or went out of scope, so using it is undefined behaviour and may seem to work until it suddenly does not. After calling free, set the pointer to NULL so a later mistake fails loudly instead of silently corrupting data.', N'media/uploads/11/lesson-05-1-null-and-dangling-pointers.mp4', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 2, N'Buffer Overflows', N'A buffer overflow writes past the end of an array. C does not check array bounds, so writing to marks[10] in an array of five simply overwrites whatever lies after it. Functions such as gets and strcpy, which do not know the size of the destination, are common causes, and attackers have used overflows to take over programs. Prefer fgets and strncpy or snprintf, always pass the buffer size, and make sure loops stop at the last valid index.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), 3, N'Debugging with gdb and valgrind', N'Compile with the -g option so the debugger knows your source lines. gdb lets you run the program, set a breakpoint with break and step through the code with next, printing variables with print. When the program crashes, the backtrace command shows which functions were running. Valgrind runs the program and reports invalid reads and writes, use of uninitialised values and memory that was never freed. Run valgrind on every program you write while you are learning; most pointer bugs show up immediately.', N'media/uploads/11/lesson-05-3-debugging-with-gdb-and-valgrind.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -15, GETDATE()), N'Pitfalls Quiz', N'Check how to recognise and prevent pointer bugs.', N'media/uploads/11/quiz-pitfalls-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'Security Fundamentals', N'Understand what security means, who threatens systems and where weaknesses come from.', N'3 hours', N'media/uploads/12/chapter-01-security-fundamentals.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'The CIA Triad', N'Information security rests on three goals: confidentiality, integrity and availability, often called the CIA triad. Confidentiality means only the right people can read the data, which encryption and access control protect. Integrity means the data cannot be changed without anyone noticing, which hashes and digital signatures protect. Availability means the system works when people need it, which backups and protection against overload protect. When you judge a design, ask which of the three goals an attack would damage.', N'media/uploads/12/lesson-01-1-the-cia-triad.mp4', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Threats and Attackers', N'A threat is anything that could harm a system, and an attacker is a person or program carrying it out. Attackers range from curious beginners, to criminals who want money, to groups targeting a particular organisation. Not every incident is a deliberate attack: a lost laptop, a mistaken deletion or a failing disk are threats too. Common attacks include phishing emails that trick people into giving passwords, malware that runs on a machine and denial of service attacks that flood a site with traffic.', NULL, 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'Common Vulnerabilities', N'A vulnerability is a weakness an attacker can use. Typical ones are weak or reused passwords, software that has not been updated, data sent without encryption, programs that trust user input and systems that give users more permissions than they need. Most successful attacks use well-known problems rather than clever new ones. Lists such as the OWASP Top Ten describe the most frequent web vulnerabilities, and learning them is the quickest way to stop writing code that attackers expect.', N'media/uploads/12/lesson-01-3-common-vulnerabilities.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), N'Security Basics Quiz', N'Check the core ideas of information security.', N'media/uploads/12/quiz-security-basics-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 1;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Passwords and Hashing', N'Store passwords safely using hashes and salts.', N'4 hours', N'media/uploads/12/chapter-02-passwords-and-hashing.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'Why Hash Passwords?', N'A system should never store passwords as plain text, because anyone who reads the database, whether an attacker or a careless employee, would see every password and could try them on other sites. Instead it stores a hash. A hash function turns any input into a fixed-length string, always gives the same output for the same input and cannot be run backwards. To check a login, the system hashes what the user typed and compares it with the stored hash. A leaked database of hashes is much less useful to an attacker.', N'media/uploads/12/lesson-02-1-why-hash-passwords.png', 15, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Hashing with hashlib', N'Python''s hashlib module provides hash functions. hashlib.sha256(b"password").hexdigest() returns the SHA-256 hash of the bytes as a 64-character hexadecimal string. Text must first be turned into bytes with encode. Changing a single letter of the input changes the whole hash, so you can use hashes to check that a file has not been altered. Fast hashes such as SHA-256 are good for checking data but too fast for passwords, because an attacker can try billions of guesses a second.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'Salting and Strong Passwords', N'A salt is a random value added to a password before hashing, stored next to the hash. Salts make two users with the same password get different hashes, and defeat tables of precomputed hashes. For passwords use a deliberately slow function designed for them, such as bcrypt, scrypt or hashlib.pbkdf2_hmac with many iterations. Encourage long passphrases rather than short complicated ones, check new passwords against lists of common ones and offer two-factor authentication so a stolen password alone is not enough.', N'media/uploads/12/lesson-02-3-salting-and-strong-passwords.mp4', 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), N'Hashing Assessment', N'Hash and protect passwords correctly.', N'media/uploads/12/assessment-hashing-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 2;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'Web Security', N'Protect web applications from injection, scripting and weak transport.', N'4 hours', N'media/uploads/12/chapter-03-web-security.jpg', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'SQL Injection', N'SQL injection happens when user input is placed inside an SQL command as text. If a login query is built as "SELECT * FROM users WHERE name = ''" + name + "''" and a user types '' OR ''1''=''1, the condition becomes true for every row. Attackers use the same trick to read or delete whole tables. The defence is to use parameterised queries, where values are sent separately from the SQL, and to give the database account only the permissions the application needs. Validating input helps but is never a substitute.', N'media/uploads/12/lesson-03-1-sql-injection.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Cross-Site Scripting', N'Cross-site scripting, or XSS, happens when a site shows user input in a page without encoding it. If a comment contains a script tag and the site prints it as it is, the script runs in every visitor''s browser and can steal their session or change the page. The defence is output encoding: turn special characters such as the angle brackets into harmless text before showing them. Template engines such as Jinja do this automatically, and a Content Security Policy header adds a second layer by limiting which scripts may run.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'HTTPS and Cookies', N'HTTPS is HTTP carried inside an encrypted TLS connection, which stops other people on the network from reading or changing the traffic and proves that the server is who it claims to be. Cookies hold a login session, so protect them: the Secure flag sends the cookie only over HTTPS, the HttpOnly flag hides it from scripts and the SameSite flag limits sending it from other sites. Use a long random session id, and make sessions expire after a period of inactivity.', N'media/uploads/12/lesson-03-3-https-and-cookies.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), N'Web Security Quiz', N'Check how common web attacks work and how to stop them.', N'media/uploads/12/quiz-web-security-quiz.png', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 3;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 4, N'Encryption in Python', N'Protect data with encryption and prove who sent it with signatures.', N'5 hours', N'media/uploads/12/chapter-04-encryption-in-python.mp4', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'Symmetric Encryption', N'Symmetric encryption uses one secret key both to lock and to unlock the data. It is fast and suits large amounts of data such as files and disks. The widely used algorithm is AES. In Python the cryptography package offers Fernet, a safe, easy recipe: key = Fernet.generate_key(), then Fernet(key).encrypt(data) and decrypt(token). The difficulty is the key: anyone who has it can read the data, so it must be stored and shared securely, never written into the source code.', N'media/uploads/12/lesson-04-1-symmetric-encryption.pdf', 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Public-Key Encryption', N'Public-key, or asymmetric, encryption uses a pair of keys. Anything encrypted with the public key can be decrypted only with the matching private key, so you can publish the public key freely and keep the private key secret. This solves the problem of sharing a secret with someone you have never met. It is slower than symmetric encryption, so in practice it is used to exchange a symmetric key, which then encrypts the data. HTTPS, SSH and secure email all work this way. RSA and elliptic-curve systems are common.', NULL, 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'Digital Signatures', N'A digital signature proves who created a message and that it has not been changed. The sender hashes the message and encrypts the hash with their private key; anyone can check it with the public key. If even one character of the message changes, the check fails. Signatures protect software downloads, documents and the certificates that websites use. They provide integrity and authenticity, but not confidentiality: a signed message can still be read by everyone unless it is also encrypted.', N'media/uploads/12/lesson-04-3-digital-signatures.jpg', 25, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Assessment] ([DateCreation], [DateUpdate], [AssessmentTitle], [AssessmentDescription], [AssessmentMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), N'Encryption Assessment', N'Choose and use encryption correctly.', N'media/uploads/12/assessment-encryption-assessment.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 4;
INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 5, N'Securing an Application', N'Put the ideas together to make a Python application harder to attack.', N'4 hours', N'media/uploads/12/chapter-05-securing-an-application.png', c.[CourseId], c.[TeacherId] FROM [dbo].[Course] c WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python';
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 1, N'Input Validation', N'Treat every value that comes from outside the program as untrusted: form fields, URLs, files, headers and even data from other services. Validate on the server, because checks in the browser can be bypassed. Prefer an allow list that states exactly what is accepted, such as digits only and at most ten characters, over a block list of bad values. Check the type, length, range and format, reject anything else with a clear message and never repair input by guessing what the user meant.', N'media/uploads/12/lesson-05-1-input-validation.mp4', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 2, N'Logging and Monitoring', N'You cannot respond to an attack you cannot see. Log important events: sign-ins and failures, changes to permissions, errors and unusual requests, each with a time and the user involved. Never write passwords, keys or full card numbers to a log. Python''s logging module supports levels such as INFO, WARNING and ERROR and can write to files. Review the logs, and set alerts for patterns such as many failed sign-ins from one address, which often signal a guessing attack.', NULL, 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[SubChapter] ([DateCreation], [DateUpdate], [SubChapterOrder], [SubChapterTitle], [SubChapterContent], [SubChapterMediaLink], [SubChapterDuration], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), 3, N'A Security Checklist', N'Before releasing an application, go through a checklist. Are all passwords hashed with a slow salted function? Are all database queries parameterised? Is every page served over HTTPS with secure cookies? Is user input validated and output encoded? Do accounts have only the permissions they need? Are secrets kept out of the source code and version control? Are the libraries up to date? Is there a tested backup and a plan for what to do after an incident? Repeat the checklist whenever the application changes.', N'media/uploads/12/lesson-05-3-a-security-checklist.pdf', 20, ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 5;
INSERT INTO [dbo].[Quiz] ([DateCreation], [DateUpdate], [QuizTitle], [QuizDescription], [QuizMediaLink], [ChapterId], [TeacherId])
SELECT DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, -11, GETDATE()), N'Security Review Quiz', N'Check how to secure an application before release.', N'media/uploads/12/quiz-security-review-quiz.pdf', ch.[ChapterId], ch.[TeacherId] FROM [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 5;

-- 11.2. QUESTIONS (multiple choice 3 options: 2 marks; fill in the blank 3 marks; coding 5 marks)
DECLARE @NcTest INT, @NcTeacher INT, @NcQ INT;
SET @NcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Databases with Python');
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 1);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is one row of a table called?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A record', 1, 1, @NcQ), (N'A column', 0, 2, @NcQ), (N'A schema', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does a primary key do?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Stores the largest value', 0, 1, @NcQ), (N'Identifies each row exactly once', 1, 2, @NcQ), (N'Sorts the table', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which Python module includes a built-in SQLite database?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'random', 0, 1, @NcQ), (N'csv', 0, 2, @NcQ), (N'sqlite3', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why use a database instead of a plain text file?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'It finds and protects data reliably even with many records', 1, 1, @NcQ), (N'It makes the program shorter', 0, 2, @NcQ), (N'It removes the need for Python', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which command reads rows from a table?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'SELECT', 1, 1, @NcQ), (N'INSERT', 0, 2, @NcQ), (N'DELETE', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What happens if UPDATE has no WHERE clause?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Nothing is changed', 0, 1, @NcQ), (N'Every row is changed', 1, 2, @NcQ), (N'Only the first row is changed', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ clause sorts the rows of a result.', 'FillBlank', 3, 3, N'ORDER BY, order by', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The ____ function counts the rows in a result.', 'FillBlank', 3, 4, N'COUNT, count, COUNT(*), count(*)', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a SQL query that returns the name and age of every student older than 18, oldest first.', 'Coding', 5, 5, NULL, N'SELECT name, age FROM students WHERE age > 18 ORDER BY age DESC;', N'1 mark for SELECT name, age, 1 mark for FROM students, 2 marks for the WHERE condition, 1 mark for ORDER BY age DESC', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 3);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which call opens or creates an SQLite database file?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'sqlite3.connect()', 1, 1, @NcQ), (N'sqlite3.open()', 0, 2, @NcQ), (N'sqlite3.create()', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which method saves changes made through a connection?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'save()', 0, 1, @NcQ), (N'commit()', 1, 2, @NcQ), (N'write()', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does a cursor do?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Draws the table on screen', 0, 1, @NcQ), (N'Closes the database', 0, 2, @NcQ), (N'Runs SQL commands and fetches results', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which placeholder does sqlite3 use for a parameter?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'?', 1, 1, @NcQ), (N'%d', 0, 2, @NcQ), (N'#', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 4);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a foreign key?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A column that refers to the primary key of another table', 1, 1, @NcQ), (N'The first column of a table', 0, 2, @NcQ), (N'A secret password for the database', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which join keeps only rows that match in both tables?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'LEFT JOIN', 0, 1, @NcQ), (N'INNER JOIN', 1, 2, @NcQ), (N'CROSS JOIN', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A relationship where one customer has many orders is called one to ____.', 'FillBlank', 3, 3, N'many', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Arranging data so that each fact is stored once is called ____.', 'FillBlank', 3, 4, N'normalisation, normalization', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a SQL query that lists each customer''s name and the total of each of their orders, using customer_id to join customers and orders.', 'Coding', 5, 5, NULL, N'SELECT customers.name, orders.total FROM customers JOIN orders ON orders.customer_id = customers.id;', N'1 mark for the selected columns, 1 mark for FROM customers, 2 marks for JOIN orders, 1 mark for the ON condition', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Databases with Python' AND ch.[ChapterNum] = 5);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What should you do before writing the code of a database project?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Plan the tables, keys and questions', 1, 1, @NcQ), (N'Choose the colours', 0, 2, @NcQ), (N'Delete old data', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why keep all the SQL in one module?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'SQL only works in one file', 0, 1, @NcQ), (N'The rest of the program stays simple and easier to change', 1, 2, @NcQ), (N'It makes queries run faster', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which statement creates a table only if it is missing?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'CREATE TABLE ONCE', 0, 1, @NcQ), (N'MAKE TABLE', 0, 2, @NcQ), (N'CREATE TABLE IF NOT EXISTS', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a simple way to back up an SQLite database?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Copy the database file', 1, 1, @NcQ), (N'Print every table', 0, 2, @NcQ), (N'Rename the tables', 0, 3, @NcQ);
SET @NcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'C Pointers Workshop');
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 1);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the address of a variable?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The number of its first byte in memory', 1, 1, @NcQ), (N'Its value', 0, 2, @NcQ), (N'Its name', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does int *p; declare?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'An integer called p', 0, 1, @NcQ), (N'A pointer that can hold the address of an int', 1, 2, @NcQ), (N'An array of ints', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does *p do when p is a pointer?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Returns the address of p', 0, 1, @NcQ), (N'Deletes p', 0, 2, @NcQ), (N'Reads or changes the value p points to', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which format specifier prints an address with printf?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'%p', 1, 1, @NcQ), (N'%d', 0, 2, @NcQ), (N'%s', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'If p points to the first int of an array, what does p + 1 point to?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The second int', 1, 1, @NcQ), (N'The same int', 0, 2, @NcQ), (N'The next byte', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which expression is the same as marks[i]?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'marks + i', 0, 1, @NcQ), (N'*(marks + i)', 1, 2, @NcQ), (N'&marks[i]', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A C string ends with the ____ character.', 'FillBlank', 3, 3, N'null, NUL, ''\0'', \0', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The standard function ____ returns the length of a string.', 'FillBlank', 3, 4, N'strlen, strlen()', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write a function int sum(int *a, int n) that returns the sum of the n ints that a points to, using pointer arithmetic.', 'Coding', 5, 5, NULL, N'int sum(int *a, int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        total += *(a + i);
    }
    return total;
}', N'1 mark for the signature, 1 mark for the loop, 2 marks for *(a + i), 1 mark for returning the total', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 3);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why pass a pointer to a function?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'So the function can change the caller''s variable', 1, 1, @NcQ), (N'To make the function faster to write', 0, 2, @NcQ), (N'Because C cannot pass numbers', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is wrong with returning the address of a local variable?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Pointers cannot be returned', 0, 1, @NcQ), (N'The variable no longer exists after the function ends', 1, 2, @NcQ), (N'It is always slower', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does const int *p promise?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'p can never be changed', 0, 1, @NcQ), (N'The int is stored on the heap', 0, 2, @NcQ), (N'The function will not change the int through p', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which declaration is a pointer to a function taking two ints and returning an int?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'int (*op)(int, int);', 1, 1, @NcQ), (N'int *op(int, int);', 0, 2, @NcQ), (N'int op*(int, int);', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 4);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does malloc return when it cannot allocate memory?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'NULL', 1, 1, @NcQ), (N'0 bytes', 0, 2, @NcQ), (N'A random address', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a memory leak?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Memory that is too small', 0, 1, @NcQ), (N'Memory that was allocated and never freed', 1, 2, @NcQ), (N'A pointer that points to NULL', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Memory obtained with malloc must be released with ____.', 'FillBlank', 3, 3, N'free, free()', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The function ____ changes the size of a block that was already allocated.', 'FillBlank', 3, 4, N'realloc, realloc()', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write C code that allocates room for 5 ints, checks that the allocation worked, sets the first one to 42 and then frees the memory.', 'Coding', 5, 5, NULL, N'int *a = malloc(5 * sizeof(int));
if (a == NULL) {
    return 1;
}
a[0] = 42;
free(a);', N'2 marks for malloc with sizeof, 1 mark for the NULL check, 1 mark for setting a[0], 1 mark for free', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'C Pointers Workshop' AND ch.[ChapterNum] = 5);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What happens when you dereference a NULL pointer?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The program usually crashes with a segmentation fault', 1, 1, @NcQ), (N'It returns zero', 0, 2, @NcQ), (N'It allocates memory', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a dangling pointer?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A pointer that is NULL', 0, 1, @NcQ), (N'A pointer to memory that has been freed or no longer exists', 1, 2, @NcQ), (N'A pointer to a function', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which tool reports memory that was never freed?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'printf', 0, 1, @NcQ), (N'make', 0, 2, @NcQ), (N'valgrind', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What causes a buffer overflow?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Writing past the end of an array', 1, 1, @NcQ), (N'Reading a file', 0, 2, @NcQ), (N'Declaring too many variables', 0, 3, @NcQ);
SET @NcTeacher = (SELECT [TeacherId] FROM [dbo].[Course] WHERE [CourseTitle] = N'Cybersecurity Basics with Python');
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 1);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which goal of the CIA triad means data cannot be changed unnoticed?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Integrity', 1, 1, @NcQ), (N'Confidentiality', 0, 2, @NcQ), (N'Availability', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is phishing?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Flooding a site with traffic', 0, 1, @NcQ), (N'Tricking people into revealing information', 1, 2, @NcQ), (N'Updating software', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which is a common vulnerability?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Installing updates promptly', 0, 1, @NcQ), (N'Encrypting traffic', 0, 2, @NcQ), (N'Reusing the same weak password everywhere', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does confidentiality protect?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Who can read the data', 1, 1, @NcQ), (N'How fast the system runs', 0, 2, @NcQ), (N'How much storage is used', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 2);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Why are passwords stored as hashes?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A leaked database does not reveal the passwords', 1, 1, @NcQ), (N'Hashes are easier to remember', 0, 2, @NcQ), (N'Hashes can be reversed to the password', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is a salt?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A second password', 0, 1, @NcQ), (N'A random value added to a password before hashing', 1, 2, @NcQ), (N'A type of encryption key', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The Python module ____ provides functions such as sha256.', 'FillBlank', 3, 3, N'hashlib', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A hash function always gives the ____ output for the same input.', 'FillBlank', 3, 4, N'same, identical', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write Python code that prints the SHA-256 hexadecimal hash of the text hello.', 'Coding', 5, 5, NULL, N'import hashlib
print(hashlib.sha256("hello".encode()).hexdigest())', N'1 mark for the import, 2 marks for sha256 on encoded text, 2 marks for hexdigest and print', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 3);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which defence best stops SQL injection?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Parameterised queries', 1, 1, @NcQ), (N'Longer passwords', 0, 2, @NcQ), (N'Hiding the table names', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does cross-site scripting let an attacker do?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Read the server''s source code', 0, 1, @NcQ), (N'Run a script in another user''s browser', 1, 2, @NcQ), (N'Speed up a site', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does the HttpOnly cookie flag do?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Encrypts the cookie value', 0, 1, @NcQ), (N'Makes the cookie permanent', 0, 2, @NcQ), (N'Hides the cookie from scripts', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What does HTTPS add to HTTP?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Encryption of the traffic', 1, 1, @NcQ), (N'Faster downloads', 0, 2, @NcQ), (N'Free hosting', 0, 3, @NcQ);
SET @NcTest = (SELECT t.[AssessmentId] FROM [dbo].[Assessment] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 4);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'How many keys does symmetric encryption use?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'One shared secret key', 1, 1, @NcQ), (N'Two different keys', 0, 2, @NcQ), (N'No keys', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which key do you keep secret in public-key encryption?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'The public key', 0, 1, @NcQ), (N'The private key', 1, 2, @NcQ), (N'Both keys', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'A digital signature proves who sent a message and that it was not ____.', 'FillBlank', 3, 3, N'changed, altered, modified, tampered', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'The widely used symmetric encryption algorithm is called ____.', 'FillBlank', 3, 4, N'AES, aes', NULL, NULL, @NcTeacher, NULL, @NcTest, NULL);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Write Python code that uses the cryptography package to create a Fernet key and encrypt the bytes b"secret".', 'Coding', 5, 5, NULL, N'from cryptography.fernet import Fernet
key = Fernet.generate_key()
token = Fernet(key).encrypt(b"secret")', N'1 mark for the import, 2 marks for generating the key, 2 marks for encrypt', @NcTeacher, NULL, @NcTest, NULL);
SET @NcTest = (SELECT t.[QuizId] FROM [dbo].[Quiz] t INNER JOIN [dbo].[Chapter] ch INNER JOIN [dbo].[Course] c ON c.[CourseId] = ch.[CourseId] ON ch.[ChapterId] = t.[ChapterId] WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND ch.[ChapterNum] = 5);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Where should input be validated?', 'MCQ', 2, 1, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'On the server', 1, 1, @NcQ), (N'Only in the browser', 0, 2, @NcQ), (N'Nowhere, if the form looks right', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'Which should never be written to a log?', 'MCQ', 2, 2, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Time of a sign-in', 0, 1, @NcQ), (N'Passwords and secret keys', 1, 2, @NcQ), (N'Error messages', 0, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is an allow list?', 'MCQ', 2, 3, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'A list of blocked users', 0, 1, @NcQ), (N'A list of log files', 0, 2, @NcQ), (N'A list of exactly what input is accepted', 1, 3, @NcQ);
INSERT INTO [dbo].[Question] ([QuestionContent], [QuestionType], [QuestionScore], [QuestionOrder], [AcceptedAnswers], [ModelAnswer], [MarkingGuide], [TeacherId], [QuizId], [AssessmentId], [ExamId]) VALUES (N'What is the principle of least privilege?', 'MCQ', 2, 4, NULL, NULL, NULL, @NcTeacher, @NcTest, NULL, NULL);
SET @NcQ = SCOPE_IDENTITY();
INSERT INTO [dbo].[MCQ_Option] ([OptionContent], [IsCorrect], [OptionOrder], [QuestionId]) VALUES (N'Give accounts only the permissions they need', 1, 1, @NcQ), (N'Give every account full access', 0, 2, @NcQ), (N'Remove all accounts', 0, 3, @NcQ);

-- 11.3. LEARNERS: where each one is in the course (ChapNum: the chapter they are on; the number after the last chapter + 1 means the final exam was submitted)
CREATE TABLE #NcProg ([Email] NVARCHAR(50) NOT NULL, [Course] NVARCHAR(255) NOT NULL, [ChapNum] INT NOT NULL, [DaysAgo] INT NOT NULL);
INSERT INTO #NcProg ([Email], [Course], [ChapNum], [DaysAgo]) VALUES
(N'kavitha.raj@gmail.com', N'Databases with Python', 7, 24),
(N'jasonkoh@gmail.com', N'Databases with Python', 7, 23),
(N'ethanlim2002@gmail.com', N'Databases with Python', 7, 22),
(N'farah.aziz@gmail.com', N'Databases with Python', 5, 24),
(N'gavinooi@gmail.com', N'Databases with Python', 3, 23),
(N'wan1234@gmail.com', N'Databases with Python', 2, 22),
(N'hana.yusof@gmail.com', N'Databases with Python', 1, 24),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', 7, 15),
(N'lucasng99@gmail.com', N'C Pointers Workshop', 7, 14),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', 7, 13),
(N'divya.menon@gmail.com', N'C Pointers Workshop', 4, 15),
(N'jasonkoh@gmail.com', N'C Pointers Workshop', 2, 14),
(N'ethanlim2002@gmail.com', N'C Pointers Workshop', 1, 13),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', 7, 12),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', 7, 11),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', 7, 10),
(N'gavinooi@gmail.com', N'Cybersecurity Basics with Python', 5, 12),
(N'kavitha.raj@gmail.com', N'Cybersecurity Basics with Python', 3, 11),
(N'lucasng99@gmail.com', N'Cybersecurity Basics with Python', 2, 10),
(N'hana.yusof@gmail.com', N'Cybersecurity Basics with Python', 1, 12);
UPDATE p SET p.[ChapNum] = x.[ChapNum], p.[EnrolledDate] = DATEADD(DAY, -x.[DaysAgo], GETDATE()) FROM [dbo].[LearnerProgress] p INNER JOIN [dbo].[Learner] l ON l.[LearnerId] = p.[LearnerId] INNER JOIN [dbo].[Course] c ON c.[CourseId] = p.[CourseId] INNER JOIN #NcProg x ON x.[Email] = l.[Email] AND x.[Course] = c.[CourseTitle];
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate]) SELECT l.[LearnerId], c.[CourseId], x.[ChapNum], DATEADD(DAY, -x.[DaysAgo], GETDATE()) FROM #NcProg x INNER JOIN [dbo].[Learner] l ON l.[Email] = x.[Email] INNER JOIN [dbo].[Course] c ON c.[CourseTitle] = x.[Course] WHERE NOT EXISTS (SELECT 1 FROM [dbo].[LearnerProgress] p WHERE p.[LearnerId] = l.[LearnerId] AND p.[CourseId] = c.[CourseId]);
DROP TABLE #NcProg;

-- 11.4. ATTEMPTS: graded quizzes and assessments, a few waiting for marking, and the graded final exams
CREATE TABLE #NcAtt ([Id] INT IDENTITY(1,1) PRIMARY KEY, [LearnerId] INT NOT NULL, [QuizId] INT NULL, [AssessmentId] INT NULL, [ExamId] INT NULL, [HoursAgo] INT NOT NULL, [Skill] INT NOT NULL, [State] NVARCHAR(10) NOT NULL, [Note] NVARCHAR(MAX) NULL, [TA_Id] INT NULL);
INSERT INTO #NcAtt ([LearnerId], [QuizId], [AssessmentId], [ExamId], [HoursAgo], [Skill], [State], [Note], [TA_Id])
SELECT l.[LearnerId], qz.[QuizId], asm.[AssessmentId], ex.[ExamId], v.[Hours], v.[Skill], v.[State], v.[Note], ta.[TA_Id]
FROM (VALUES
(N'kavitha.raj@gmail.com', N'Databases with Python', N'quiz', 1, 483, 100, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Databases with Python', N'asm', 2, 390, 100, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Databases with Python', N'quiz', 3, 297, 100, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Databases with Python', N'asm', 4, 204, 100, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Databases with Python', N'quiz', 5, 111, 100, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'Databases with Python', N'quiz', 1, 464, 4, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'Databases with Python', N'asm', 2, 371, 4, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'Databases with Python', N'quiz', 3, 278, 4, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'Databases with Python', N'asm', 4, 185, 4, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'Databases with Python', N'quiz', 5, 74, 4, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'quiz', 1, 445, 100, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'asm', 2, 352, 100, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'quiz', 3, 241, 100, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'asm', 4, 148, 100, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'quiz', 5, 55, 100, N'graded', NULL, NULL),
(N'ethanlim2002@gmail.com', N'Databases with Python', N'exam', NULL, 42, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Databases with Python', N'quiz', 1, 480, 4, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Databases with Python', N'asm', 2, 387, 4, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Databases with Python', N'quiz', 3, 294, 4, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Databases with Python', N'asm', 4, 201, 4, N'graded', NULL, NULL),
(N'gavinooi@gmail.com', N'Databases with Python', N'quiz', 1, 461, 3, N'graded', NULL, NULL),
(N'gavinooi@gmail.com', N'Databases with Python', N'asm', 2, 368, 3, N'pending', NULL, NULL),
(N'wan1234@gmail.com', N'Databases with Python', N'quiz', 1, 442, 100, N'graded', NULL, NULL),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', N'quiz', 1, 315, 100, N'graded', NULL, NULL),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', N'asm', 2, 270, 100, N'graded', NULL, NULL),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', N'quiz', 3, 225, 100, N'graded', NULL, NULL),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', N'asm', 4, 180, 100, N'graded', NULL, NULL),
(N'aisyah.rahman@gmail.com', N'C Pointers Workshop', N'quiz', 5, 135, 100, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'C Pointers Workshop', N'quiz', 1, 296, 4, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'C Pointers Workshop', N'asm', 2, 251, 4, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'C Pointers Workshop', N'quiz', 3, 206, 4, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'C Pointers Workshop', N'asm', 4, 161, 4, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'C Pointers Workshop', N'quiz', 5, 98, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'quiz', 1, 277, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'asm', 2, 232, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'quiz', 3, 169, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'asm', 4, 124, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'quiz', 5, 79, 4, N'graded', NULL, NULL),
(N'iman.hakim@gmail.com', N'C Pointers Workshop', N'exam', NULL, 42, 4, N'graded', NULL, NULL),
(N'divya.menon@gmail.com', N'C Pointers Workshop', N'quiz', 1, 312, 100, N'graded', NULL, NULL),
(N'divya.menon@gmail.com', N'C Pointers Workshop', N'asm', 2, 267, 100, N'ta', N'Fill-in answers match the accepted answers. The coding answer is missing the NULL check, so I gave partial marks.', N'ta1234@gmail.com'),
(N'divya.menon@gmail.com', N'C Pointers Workshop', N'quiz', 3, 222, 100, N'graded', NULL, NULL),
(N'jasonkoh@gmail.com', N'C Pointers Workshop', N'quiz', 1, 293, 3, N'graded', NULL, NULL),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 267, 100, N'graded', NULL, NULL),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', N'asm', 2, 246, 100, N'graded', NULL, NULL),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 3, 225, 100, N'graded', NULL, NULL),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', N'asm', 4, 204, 100, N'graded', NULL, NULL),
(N'chenwei.lee@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 5, 183, 100, N'graded', NULL, NULL),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 248, 4, N'graded', NULL, NULL),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', N'asm', 2, 227, 4, N'graded', NULL, NULL),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 3, 206, 4, N'graded', NULL, NULL),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', N'asm', 4, 185, 4, N'graded', NULL, NULL),
(N'bentan88@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 5, 146, 4, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 229, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'asm', 2, 208, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 3, 169, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'asm', 4, 148, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 5, 127, 100, N'graded', NULL, NULL),
(N'farah.aziz@gmail.com', N'Cybersecurity Basics with Python', N'exam', NULL, 42, 100, N'graded', NULL, NULL),
(N'gavinooi@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 264, 4, N'graded', NULL, NULL),
(N'gavinooi@gmail.com', N'Cybersecurity Basics with Python', N'asm', 2, 243, 4, N'pending', NULL, NULL),
(N'gavinooi@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 3, 222, 4, N'graded', NULL, NULL),
(N'gavinooi@gmail.com', N'Cybersecurity Basics with Python', N'asm', 4, 201, 4, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 245, 100, N'graded', NULL, NULL),
(N'kavitha.raj@gmail.com', N'Cybersecurity Basics with Python', N'asm', 2, 224, 100, N'graded', NULL, NULL),
(N'lucasng99@gmail.com', N'Cybersecurity Basics with Python', N'quiz', 1, 226, 3, N'graded', NULL, NULL)
) v ([Email], [Course], [Kind], [Chap], [Hours], [Skill], [State], [Note], [TaEmail])
INNER JOIN [dbo].[Learner] l ON l.[Email] = v.[Email]
INNER JOIN [dbo].[Course] c ON c.[CourseTitle] = v.[Course]
LEFT JOIN [dbo].[Chapter] ch ON ch.[CourseId] = c.[CourseId] AND ch.[ChapterNum] = v.[Chap]
LEFT JOIN [dbo].[Quiz] qz ON qz.[ChapterId] = ch.[ChapterId] AND v.[Kind] = 'quiz'
LEFT JOIN [dbo].[Assessment] asm ON asm.[ChapterId] = ch.[ChapterId] AND v.[Kind] = 'asm'
LEFT JOIN [dbo].[Exam] ex ON ex.[CourseId] = c.[CourseId] AND v.[Kind] = 'exam'
LEFT JOIN [dbo].[Teaching_Assistant] ta ON ta.[Email] = v.[TaEmail];
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [QuizId], [AssessmentId], [ExamId])
SELECT DATEADD(HOUR, -x.[HoursAgo], GETDATE()), 'completed', x.[LearnerId], x.[QuizId], x.[AssessmentId], x.[ExamId] FROM #NcAtt x ORDER BY x.[Id];

-- The answers: a multiple-choice answer is the id of the option picked, the others are text. A learner's skill sets how many are wrong (100 = none,
-- 4 = about one in four, 3 = about one in three). Graded attempts get a verdict and marks for every answer, the others 'pending' answers worth 0.
INSERT INTO [dbo].[AttemptAnswer] ([AttemptId], [QuestionId], [AnswerContent], [IsCorrect], [ObtainedScore], [TeacherComment])
SELECT a.[AttemptId], q.[QuestionId],
       CASE q.[QuestionType]
            WHEN 'MCQ' THEN CAST((SELECT TOP 1 o.[MCQ_OptionId] FROM [dbo].[MCQ_Option] o WHERE o.[QuestionId] = q.[QuestionId] AND o.[IsCorrect] = IIF(f.[Wrong] = 1, 0, 1) ORDER BY o.[OptionOrder]) AS NVARCHAR(MAX))
            WHEN 'FillBlank' THEN IIF(f.[Wrong] = 1, N'not sure', LTRIM(RTRIM(LEFT(q.[AcceptedAnswers] + ',', CHARINDEX(',', q.[AcceptedAnswers] + ',') - 1))))
            ELSE IIF(f.[Wrong] = 1, LEFT(q.[ModelAnswer], CEILING(LEN(q.[ModelAnswer]) * 0.6)), q.[ModelAnswer]) END,
       IIF(x.[State] <> 'graded', 'pending', IIF(f.[Wrong] = 0, 'correct', IIF(q.[QuestionType] = 'Coding', 'partial', 'incorrect'))),
       IIF(x.[State] <> 'graded', IIF(x.[State] = 'ta' AND q.[QuestionType] <> 'MCQ', FLOOR(q.[QuestionScore] * 0.8), 0),
           IIF(f.[Wrong] = 0, q.[QuestionScore], IIF(q.[QuestionType] = 'Coding', FLOOR(q.[QuestionScore] * 0.5), 0))),
       IIF(x.[State] = 'graded' AND f.[Wrong] = 0, N'Well done', IIF(x.[State] = 'ta' AND q.[QuestionType] <> 'MCQ', N'Provisional mark from the teaching assistant.', N''))
FROM [dbo].[Attempt] a
INNER JOIN #NcAtt x ON x.[LearnerId] = a.[LearnerId] AND ISNULL(x.[QuizId], 0) = ISNULL(a.[QuizId], 0) AND ISNULL(x.[AssessmentId], 0) = ISNULL(a.[AssessmentId], 0) AND ISNULL(x.[ExamId], 0) = ISNULL(a.[ExamId], 0)
INNER JOIN [dbo].[Question] q ON (q.[ExamId] = a.[ExamId] OR q.[QuizId] = a.[QuizId] OR q.[AssessmentId] = a.[AssessmentId])
CROSS APPLY (SELECT IIF(x.[Skill] >= 100, 0, IIF((q.[QuestionOrder] + a.[AttemptId]) % x.[Skill] = 0, 1, 0)) AS [Wrong]) f
WHERE a.[AttemptId] > @NcFirst AND NOT EXISTS (SELECT 1 FROM [dbo].[AttemptAnswer] e WHERE e.[AttemptId] = a.[AttemptId] AND e.[QuestionId] = q.[QuestionId]);

-- the Result of every graded attempt, worked out from its answers
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId])
SELECT t.[Total], IIF(t.[Percent] >= 80, 'A', IIF(t.[Percent] >= 70, 'B', IIF(t.[Percent] >= 60, 'C', IIF(t.[Percent] >= 50, 'D', 'F')))), t.[Percent],
       IIF(t.[Percent] >= 80, N'Great work.', IIF(t.[Percent] >= 50, N'Good effort. Review the questions you missed.', N'Please review the chapter and try the practice again.')), t.[AttemptId]
FROM (SELECT s.[AttemptId], s.[Total], IIF(s.[Max] > 0, ROUND(s.[Total] * 100.0 / s.[Max], 1), 0) AS [Percent]
      FROM (SELECT a.[AttemptId],
                   (SELECT ISNULL(SUM(aa.[ObtainedScore]), 0) FROM [dbo].[AttemptAnswer] aa WHERE aa.[AttemptId] = a.[AttemptId]) AS [Total],
                   (SELECT ISNULL(SUM(q.[QuestionScore]), 0) FROM [dbo].[Question] q WHERE q.[ExamId] = a.[ExamId] OR q.[QuizId] = a.[QuizId] OR q.[AssessmentId] = a.[AssessmentId]) AS [Max]
            FROM [dbo].[Attempt] a INNER JOIN #NcAtt x ON x.[LearnerId] = a.[LearnerId] AND ISNULL(x.[QuizId], 0) = ISNULL(a.[QuizId], 0) AND ISNULL(x.[AssessmentId], 0) = ISNULL(a.[AssessmentId], 0) AND ISNULL(x.[ExamId], 0) = ISNULL(a.[ExamId], 0)
            WHERE a.[AttemptId] > @NcFirst AND x.[State] = 'graded') s) t;

-- the grading progress: the teacher finished the graded ones; a teaching assistant reviewed the 'ta' ones
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId])
SELECT IIF(x.[State] = 'graded', 'completed', 'Reviewed'), ISNULL(x.[Note], N''), IIF(x.[State] = 'graded', c.[TeacherId], NULL), x.[TA_Id], a.[AttemptId]
FROM [dbo].[Attempt] a
INNER JOIN #NcAtt x ON x.[LearnerId] = a.[LearnerId] AND ISNULL(x.[QuizId], 0) = ISNULL(a.[QuizId], 0) AND ISNULL(x.[AssessmentId], 0) = ISNULL(a.[AssessmentId], 0) AND ISNULL(x.[ExamId], 0) = ISNULL(a.[ExamId], 0)
LEFT JOIN [dbo].[Exam] e ON e.[ExamId] = a.[ExamId]
LEFT JOIN [dbo].[Quiz] z ON z.[QuizId] = a.[QuizId] LEFT JOIN [dbo].[Assessment] s ON s.[AssessmentId] = a.[AssessmentId]
LEFT JOIN [dbo].[Chapter] ch ON ch.[ChapterId] = COALESCE(z.[ChapterId], s.[ChapterId])
INNER JOIN [dbo].[Course] c ON c.[CourseId] = COALESCE(e.[CourseId], ch.[CourseId])
WHERE a.[AttemptId] > @NcFirst AND x.[State] IN ('graded', 'ta');

-- a passed final exam earns the certificate of the course, issued in the teacher's name
INSERT INTO [dbo].[Certificate] ([Issuer], [IssueDate], [LearnerId], [CourseId])
SELECT t.[Name], DATEADD(HOUR, 2, a.[AttemptDate]), a.[LearnerId], e.[CourseId]
FROM [dbo].[Attempt] a INNER JOIN [dbo].[Result] r ON r.[AttemptId] = a.[AttemptId] INNER JOIN [dbo].[Exam] e ON e.[ExamId] = a.[ExamId]
INNER JOIN [dbo].[Course] c ON c.[CourseId] = e.[CourseId] INNER JOIN [dbo].[Teacher] t ON t.[TeacherId] = c.[TeacherId]
WHERE a.[AttemptId] > @NcFirst AND r.[Average] >= e.[PassMark]
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Certificate] ce WHERE ce.[LearnerId] = a.[LearnerId] AND ce.[CourseId] = e.[CourseId]);

DROP TABLE #NcAtt;

-- 11.5. REVIEWS from the learners who finished
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Clear lessons and the sqlite3 practice made SQL feel easy.', 5.0, DATEADD(DAY, -3, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'Databases with Python' AND l.[Email] = N'ethanlim2002@gmail.com';
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Good pace. The joins chapter could use one more example.', 4.0, DATEADD(DAY, -4, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'Databases with Python' AND l.[Email] = N'kavitha.raj@gmail.com';
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Finally understood pointers and dynamic memory. Loved the valgrind part.', 4.5, DATEADD(DAY, -2, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'C Pointers Workshop' AND l.[Email] = N'iman.hakim@gmail.com';
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Hard topic, explained step by step.', 4.0, DATEADD(DAY, -3, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'C Pointers Workshop' AND l.[Email] = N'aisyah.rahman@gmail.com';
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Practical and well organised. The hashing and SQL injection lessons were great.', 5.0, DATEADD(DAY, -2, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND l.[Email] = N'farah.aziz@gmail.com';
INSERT INTO [dbo].[Course_Review] ([CourseFeedBack], [Rating], [SubmissionDate], [CourseId], [LearnerId]) SELECT N'Good introduction to web security.', 4.0, DATEADD(DAY, -3, GETDATE()), c.[CourseId], l.[LearnerId] FROM [dbo].[Course] c CROSS JOIN [dbo].[Learner] l WHERE c.[CourseTitle] = N'Cybersecurity Basics with Python' AND l.[Email] = N'chenwei.lee@gmail.com';

PRINT 'Content and learner history added for three courses.';
