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
    [Title]          NVARCHAR (50)  NOT NULL,
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
-- Forum posts (Backend Phase 5, Step 5.1)
-- A teacher sees the posts they wrote and the posts of learners enrolled in one of their courses.
-- Kylan is in Bryan's courses, Wan is in Bryan's Python course and Sarah's C course.
-- Post_Reply.IsPinned is 'Yes' or 'No'.
-- ==========================================
DECLARE @PostId INT, @ThreadId INT;

INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId])
VALUES ('What is String in Python?', 'I am currently going through the Python Programming Fundamentals course and I am a bit confused about strings. What exactly is a string, and how is it different from a list?', DATEADD(DAY, -2, GETDATE()), @KylanId, 'Python,Fundamental', NULL);
SET @PostId = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId])
VALUES ('A string is just a sequence of characters. They are strictly immutable.', 'No', NULL, @PostId, @WanId, NULL, NULL);
SET @ThreadId = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId])
VALUES ('Wan is correct! Because strings are immutable, if you want to "modify" one you actually create a brand new string.', 'Yes', DATEADD(DAY, -1, GETDATE()), @PostId, NULL, @BryanId, @ThreadId);

INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId])
VALUES ('Error setting up Visual Studio for C++', 'Every time I try to compile my first Hello World program, it throws an error. I installed Visual Studio yesterday.', DATEADD(DAY, -1, GETDATE()), @WanId, 'C++,Environment,Error', NULL);
SET @PostId = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId])
VALUES ('Check that the Desktop development with C++ workload is installed in Visual Studio Installer.', 'No', NULL, @PostId, @KylanId, NULL, NULL);

INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId])
VALUES ('Welcome to Python Programming Fundamentals', 'Introduce yourself here and tell us what you would like to build with Python.', DATEADD(DAY, -5, GETDATE()), NULL, 'Announcement', @BryanId);
SET @PostId = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId])
VALUES ('Hi everyone! I want to build a small game.', 'No', NULL, @PostId, @KylanId, NULL, NULL);

INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId])
VALUES ('Reminder: C final examination', 'The final examination for C Programming Essentials covers every chapter. Revise pointers and arrays.', DATEADD(DAY, -3, GETDATE()), NULL, 'Exam,Reminder', @SarahId);

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
DELETE FROM [dbo].[LearnerProgress] WHERE [LearnerId] IN (@BcKylan, @BcWan);
DELETE FROM [dbo].[Attempt] WHERE [LearnerId] IN (@BcKylan, @BcWan);
DELETE FROM [dbo].[Certificate] WHERE [LearnerId] IN (@BcKylan, @BcWan);
DELETE FROM [dbo].[Course_Review] WHERE [LearnerId] IN (@BcKylan, @BcWan);

-- 6.4.1. ENROLLMENTS & CURRENT CHAPTER PROGRESS
INSERT INTO [dbo].[LearnerProgress] ([LearnerId], [CourseId], [ChapNum], [EnrolledDate])
VALUES
    -- Kylan's Progress: Finished Python & Data Analysis, Ongoing Java (Ch 3), New Flask (Ch 1)
    (@BcKylan, @BcPythonCourse, 6, DATEADD(DAY, -45, GETDATE())),
    (@BcKylan, @BcDataCourse, 6, DATEADD(DAY, -30, GETDATE())),
    (@BcKylan, @BcJavaCourse, 3, DATEADD(DAY, -15, GETDATE())),
    (@BcKylan, @BcFlaskCourse, 1, DATEADD(DAY, -2, GETDATE())),

    -- Wan's Progress: Finished Java & C++, Ongoing Python (Ch 4), New Databases (Ch 1)
    (@BcWan, @BcJavaCourse, 6, DATEADD(DAY, -50, GETDATE())),
    (@BcWan, @BcCppCourse, 3, DATEADD(DAY, -35, GETDATE())), -- C++ has 2 chapters + 1 exam (Chap 3 = complete)
    (@BcWan, @BcPythonCourse, 4, DATEADD(DAY, -12, GETDATE())),
    (@BcWan, @BcDatabaseCourse, 1, DATEADD(DAY, -1, GETDATE()));


-- 6.4.2. COMPLETED FINAL EXAM ATTEMPTS (Grade Generating)
-- Kylan: Passed Python Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) 
VALUES (DATEADD(DAY, -10, GETDATE()), 'completed', @BcKylan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcPythonCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (18, 'A', 90.0, N'Excellent work.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @BcBryan, NULL, @BcAttempt);

-- Kylan: Passed Data Analysis Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) 
VALUES (DATEADD(DAY, -5, GETDATE()), 'completed', @BcKylan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcDataCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (17, 'A', 85.0, N'Great analysis.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @BcBryan, NULL, @BcAttempt);

-- Wan: Passed Java Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) 
VALUES (DATEADD(DAY, -15, GETDATE()), 'completed', @BcWan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcJavaCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (19, 'A', 95.0, N'Perfect architecture.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', @BcBryan, NULL, @BcAttempt);

-- Wan: Passed C++ Final
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [ExamId]) 
VALUES (DATEADD(DAY, -4, GETDATE()), 'completed', @BcWan, (SELECT [ExamId] FROM [dbo].[Exam] WHERE [CourseId] = @BcCppCourse));
SET @BcAttempt = SCOPE_IDENTITY();
INSERT INTO [dbo].[Result] ([TotalScore], [Grade], [Average], [ResultFeedback], [AttemptId]) VALUES (16, 'B', 80.0, N'Good pointer logic.', @BcAttempt);
INSERT INTO [dbo].[GradingProgress] ([ProgressStatus], [ProgressNotes], [TeacherId], [TA_Id], [AttemptId]) VALUES ('completed', N'', (SELECT [TeacherId] FROM [dbo].[Teacher] WHERE [Email] = 'sarahlim@edu.com.my'), NULL, @BcAttempt);


-- 6.4.3. ONGOING / IN-PROGRESS ATTEMPTS
-- Kylan: Currently taking Java OOP Assessment
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) 
VALUES (DATEADD(HOUR, -2, GETDATE()), 'in_progress', @BcKylan, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'OOP Assessment'));

-- Wan: Currently taking Python Functions Assessment
INSERT INTO [dbo].[Attempt] ([AttemptDate], [AttemptStatus], [LearnerId], [AssessmentId]) 
VALUES (DATEADD(HOUR, -1, GETDATE()), 'in_progress', @BcWan, (SELECT [AssessmentId] FROM [dbo].[Assessment] WHERE [AssessmentTitle] = N'Functions Assessment'));


-- 6.4.4. CERTIFICATES ISSUED
INSERT INTO [dbo].[Certificate] ([Issuer], [IssueDate], [LearnerId], [CourseId]) VALUES
    ('Bryan Yeong', DATEADD(DAY, -10, GETDATE()), @BcKylan, @BcPythonCourse),
    ('Bryan Yeong', DATEADD(DAY, -5, GETDATE()), @BcKylan, @BcDataCourse),
    ('Bryan Yeong', DATEADD(DAY, -15, GETDATE()), @BcWan, @BcJavaCourse),
    ('Sarah Lim', DATEADD(DAY, -4, GETDATE()), @BcWan, @BcCppCourse);

-- 6.4.5. COURSE REVIEWS
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

-- Forum posts and replies (a teacher sees their own posts and those of learners enrolled in their courses)
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'How do list comprehensions work?', N'I keep seeing [x * 2 for x in numbers] in examples. How is a list comprehension different from a normal for loop?', DATEADD(DAY, -3, GETDATE()), @BcAisyah, N'Python,Lists', NULL);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Think of it as a for loop written on one line.', 'No', NULL, @BcPost, @BcFarah, NULL, NULL);
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Exactly. Read it from the left: build x * 2 for every x in numbers. The result is a new list.', 'Yes', DATEADD(DAY, -1, GETDATE()), @BcPost, NULL, @BcBryan, (SELECT [ThreadId] FROM [dbo].[Post_Reply] WHERE [PostId] = @BcPost AND [ReplyComment] = N'Think of it as a for loop written on one line.'));
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'That makes sense now, thank you!', 'No', NULL, @BcPost, @BcAisyah, NULL, (SELECT [ThreadId] FROM [dbo].[Post_Reply] WHERE [PostId] = @BcPost AND [ReplyComment] = N'Exactly. Read it from the left: build x * 2 for every x in numbers. The result is a new list.'));
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Why does my Flask route return 404?', N'I added @app.route("/about") but the page shows Not Found.', DATEADD(DAY, -2, GETDATE()), @BcEthan, N'Flask,Errors', NULL);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Restart the development server after you add a route, and check that the function name is unique.', 'No', NULL, @BcPost, NULL, @BcAlvin, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Segmentation fault when using pointers', N'My program crashes with a segmentation fault when I print *p. What might be wrong?', DATEADD(DAY, -1, GETDATE()), @BcChen, N'C,Pointers', NULL);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Check that p points to valid memory before you dereference it. A pointer that was never assigned is the usual cause.', 'Yes', DATEADD(DAY, -1, GETDATE()), @BcPost, NULL, @BcSarah, NULL);
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'I had the same problem: I forgot to set p = &x.', 'No', NULL, @BcPost, @BcHana, NULL, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'ArrayList or LinkedList?', N'When should I use a LinkedList instead of an ArrayList in Java?', DATEADD(DAY, -4, GETDATE()), @BcGavin, N'Java,Collections', NULL);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'Use ArrayList by default. A LinkedList only helps when you insert or remove a lot in the middle of a big list.', 'No', NULL, @BcPost, NULL, @BcPriya, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'What does yield actually do?', N'I understand return, but yield confuses me. Does the function stop?', DATEADD(DAY, -2, GETDATE()), @BcDivya, N'Python,Generators', NULL);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'It pauses the function and gives back one value. The next call carries on from the same place.', 'Yes', DATEADD(DAY, -1, GETDATE()), @BcPost, NULL, @BcPriya, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Welcome to Web Apps with Python and Flask', N'Introduce yourself and share the first small site you would like to build.', DATEADD(DAY, -9, GETDATE()), NULL, N'Announcement', @BcAlvin);
SET @BcPost = SCOPE_IDENTITY();
INSERT INTO [dbo].[Post_Reply] ([ReplyComment], [IsPinned], [DatePinned], [PostId], [LearnerId], [TeacherId], [ParentThreadId]) VALUES (N'I would like to build a simple to-do list.', 'No', NULL, @BcPost, @BcAisyah, NULL, NULL);
INSERT INTO [dbo].[Forum] ([Title], [Content], [DatePosted], [LearnerId], [Tags], [TeacherId]) VALUES (N'Office hours this week', N'I will answer questions about Advanced Python Patterns and Java Collections on Thursday evening in this forum.', DATEADD(DAY, -1, GETDATE()), NULL, N'Announcement,Java,Python', @BcPriya);
SET @BcPost = SCOPE_IDENTITY();

PRINT 'Complete data for learners inserted successfully.';
