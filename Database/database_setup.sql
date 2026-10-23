USE [Codercept_db];
GO

-- ==========================================
-- 1. DROP ALL TABLES (Reverse Dependency Order)
-- ==========================================
DROP TABLE IF EXISTS [dbo].[LearnerProgress];
DROP TABLE IF EXISTS [dbo].[User_Log];
DROP TABLE IF EXISTS [dbo].[Qualification];
DROP TABLE IF EXISTS [dbo].[Post_Reply];
DROP TABLE IF EXISTS [dbo].[Moderate_Forum];
DROP TABLE IF EXISTS [dbo].[Forum];
DROP TABLE IF EXISTS [dbo].[TeacherSubject];
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
    [AdminId]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (50)  NOT NULL,
    [Email]    NVARCHAR (50)  NOT NULL,
    [Password] NVARCHAR (255) NOT NULL,
    [Role]     NVARCHAR (50)  NOT NULL,
    PRIMARY KEY CLUSTERED ([AdminId] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC)
);

CREATE TABLE [dbo].[Application] (
    [ApplicationId]      INT            IDENTITY (1, 1) NOT NULL,
    [CredentialDocument] NVARCHAR (MAX) NULL,
    [ApprovalStatus]     NVARCHAR (50)  NULL,
    [RejectReason]       NVARCHAR (MAX) NULL,
    [DateReviewed]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ApplicationId] ASC)
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
    [AccStatus]     NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    [ApplicationId] INT            NULL,
    PRIMARY KEY CLUSTERED ([TeacherId] ASC),
    UNIQUE NONCLUSTERED ([Email] ASC),
    CONSTRAINT [FK_Teacher_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
);

CREATE TABLE [dbo].[Teaching_Assistant] (
    [TA_Id]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50)  NOT NULL,
    [Email]         NVARCHAR (50)  NOT NULL,
    [Password]      NVARCHAR (255) NOT NULL,
    [Region]        NVARCHAR (50)  NULL,
    [TeachingLevel] NVARCHAR (50)  NULL,
    [AccStatus]     NVARCHAR (50)  NOT NULL DEFAULT 'Active',
    [ApplicationId] INT            NULL,
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
    [ChapterId]           INT            NOT NULL,
    [TeacherId]           INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([SubChapterId] ASC),
    CONSTRAINT [FK_SubChapter_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_SubChapter_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Assessment] (
    [AssessmentId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]          DATETIME       NOT NULL,
    [DateUpdate]            DATETIME       NOT NULL,
    [AssessmentTitle]       NVARCHAR (50)  NOT NULL,
    [AssessmentDescription] NVARCHAR (MAX) NOT NULL,
    [ChapterId]             INT            NOT NULL,
    [TeacherId]             INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([AssessmentId] ASC),
    CONSTRAINT [FK_Assessment_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_Assessment_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Exam] (
    [ExamId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]    DATETIME       NOT NULL,
    [DateUpdate]      DATETIME       NULL,
    [ExamTitle]       NVARCHAR (50)  NOT NULL,
    [ExamDescription] NVARCHAR (MAX) NOT NULL,
    [ChapterId]       INT            NOT NULL,
    [TeacherId]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ExamId] ASC),
    CONSTRAINT [FK_Exam_Chapter] FOREIGN KEY ([ChapterId]) REFERENCES [dbo].[Chapter] ([ChapterId]),
    CONSTRAINT [FK_Exam_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Quiz] (
    [QuizId]          INT            IDENTITY (1, 1) NOT NULL,
    [DateCreation]    DATETIME       NOT NULL,
    [DateUpdate]      DATETIME       NOT NULL,
    [QuizTitle]       NVARCHAR (50)  NOT NULL,
    [QuizDescription] NVARCHAR (MAX) NOT NULL,
    [SubChapterId]    INT            NOT NULL,
    [TeacherId]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([QuizId] ASC),
    CONSTRAINT [FK_Quiz_SubChapter] FOREIGN KEY ([SubChapterId]) REFERENCES [dbo].[SubChapter] ([SubChapterId]),
    CONSTRAINT [FK_Quiz_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId])
);

CREATE TABLE [dbo].[Question] (
    [QuestionId]      INT            IDENTITY (1, 1) NOT NULL,
    [QuestionContent] NVARCHAR (MAX) NOT NULL,
    [QuestionType]    NVARCHAR (50)  NOT NULL,
    [QuestionScore]   FLOAT (53)     NOT NULL,
    [TeacherId]       INT            NOT NULL,
    [QuizId]          INT            NULL,
    [AssessmentId]    INT            NULL,
    [ExamId]          INT            NULL,
    PRIMARY KEY CLUSTERED ([QuestionId] ASC),
    CONSTRAINT [FK_Question_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_Question_Quiz] FOREIGN KEY ([QuizId]) REFERENCES [dbo].[Quiz] ([QuizId]),
    CONSTRAINT [FK_Question_Assessment] FOREIGN KEY ([AssessmentId]) REFERENCES [dbo].[Assessment] ([AssessmentId]),
    CONSTRAINT [FK_Question_Exam] FOREIGN KEY ([ExamId]) REFERENCES [dbo].[Exam] ([ExamId])
);

CREATE TABLE [dbo].[MCQ_Option] (
    [MCQ_OptionId]  INT            IDENTITY (1, 1) NOT NULL,
    [OptionContent] NVARCHAR (MAX) NOT NULL,
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

CREATE TABLE [dbo].[TeacherSubject] (
    [TeacherId] INT NOT NULL,
    [SubjectId] INT NOT NULL,
    CONSTRAINT [PK_TeacherSubject] PRIMARY KEY CLUSTERED ([TeacherId] ASC, [SubjectId] ASC),
    CONSTRAINT [FK_TeacherSubject_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_TeacherSubject_Subject] FOREIGN KEY ([SubjectId]) REFERENCES [dbo].[Subject] ([SubjectId])
);

CREATE TABLE [dbo].[Forum] (
    [PostId]     INT            IDENTITY (1, 1) NOT NULL,
    [Title]      NVARCHAR (255) NOT NULL,
    [Content]    NVARCHAR (MAX) NOT NULL,
    [DatePosted] DATETIME       NOT NULL,
    [LearnerId]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([PostId] ASC),
    CONSTRAINT [FK_Forum_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId])
);

CREATE TABLE [dbo].[Moderate_Forum] (
    [PostId]         INT            NOT NULL,
    [TA_Id]          INT            NOT NULL,
    [ModerateReason] NVARCHAR (MAX) NOT NULL,
    [DateModerate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_ModerateForum] PRIMARY KEY CLUSTERED ([PostId] ASC, [TA_Id] ASC),
    CONSTRAINT [FK_ModerateForum_Forum] FOREIGN KEY ([PostId]) REFERENCES [dbo].[Forum] ([PostId]),
    CONSTRAINT [FK_ModerateForum_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

CREATE TABLE [dbo].[Post_Reply] (
    [ThreadId]     INT            IDENTITY (1, 1) NOT NULL,
    [DatePinned]   DATETIME       NULL,
    [ReplyComment] NVARCHAR (MAX) NOT NULL,
    [IsPinned]     NVARCHAR (50)  NOT NULL,
    [PostId]       INT            NOT NULL,
    [LearnerId]    INT            NULL,
    [TeacherId]    INT            NULL,
    [TA_Id]        INT            NULL,
    PRIMARY KEY CLUSTERED ([ThreadId] ASC),
    CONSTRAINT [FK_PostReply_Forum] FOREIGN KEY ([PostId]) REFERENCES [dbo].[Forum] ([PostId]),
    CONSTRAINT [FK_PostReply_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_PostReply_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_PostReply_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

CREATE TABLE [dbo].[Qualification] (
    [QualificationId]       INT            IDENTITY (1, 1) NOT NULL,
    [QualificationName]     NVARCHAR (50)  NOT NULL,
    [QualificationDocument] NVARCHAR (MAX) NOT NULL,
    [QualificationDate]     DATE           NOT NULL,
    [TeacherId]             INT            NULL,
    [TA_Id]                 INT            NULL,
    PRIMARY KEY CLUSTERED ([QualificationId] ASC),
    CONSTRAINT [FK_Qualification_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_Qualification_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

CREATE TABLE [dbo].[User_Log] (
    [LogId]         INT      IDENTITY (1, 1) NOT NULL,
    [StartDateTime] DATETIME NOT NULL,
    [EndDateTime]   DATETIME NOT NULL,
    [LearnerId]     INT      NULL,
    [TeacherId]     INT      NULL,
    [TA_Id]         INT      NULL,
    PRIMARY KEY CLUSTERED ([LogId] ASC),
    CONSTRAINT [FK_UserLog_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_UserLog_Teacher] FOREIGN KEY ([TeacherId]) REFERENCES [dbo].[Teacher] ([TeacherId]),
    CONSTRAINT [FK_UserLog_TeachingAssistant] FOREIGN KEY ([TA_Id]) REFERENCES [dbo].[Teaching_Assistant] ([TA_Id])
);

CREATE TABLE [dbo].[LearnerProgress] (
    [LearnerId] INT NOT NULL,
    [CourseId]  INT NOT NULL,
    [ChapNum]   INT NULL,
    CONSTRAINT [PK_LearnerCourse] PRIMARY KEY CLUSTERED ([LearnerId] ASC, [CourseId] ASC),
    CONSTRAINT [FK_LearnerCourse_Learner] FOREIGN KEY ([LearnerId]) REFERENCES [dbo].[Learner] ([LearnerId]),
    CONSTRAINT [FK_LearnerCourse_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Course] ([CourseId])
);

-- ==========================================
-- 3. INSERT MOCK DATA
-- ==========================================

-- Insert SuperAdmin Account
INSERT INTO [dbo].[Admin] ([Name], [Email], [Password], [Role])
VALUES ('Tang Chee Kin', 'tterry616@gmail.com', '$2a$12$L0eoOITSHTUuJNtBrjDnB.D8yZ.usDG7ZhmUhXh14lG6K6uff.7y2', 'SuperAdmin');

-- Insert Learner Account
INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES ('Kylan Shane Sedrick', 'kylan1234@gmail.com', '$2a$12$cNIkYdVSLG5nagfnR3fD4.zdnNIpAj7GHgY7a1qC2LmOPUt73mbs2', GETDATE(), 'Active', 21, 'Negeri Sembilan, Malaysia', 'Student');
INSERT INTO [dbo].[Learner] ([Name], [Email], [Password], [DateJoined], [AccStatus], [Age], [Address], [Occupation])
VALUES ('Wan Hon Kit', 'wan1234@gmail.com', '$2a$12$UtK5EgXtoXPquMKIIrcTuufwaCSlhcz6o6xpWX3zcWuDag3j5yJoO', GETDATE(), 'Active', 21, 'Penang, Malaysia', 'Student');

-- ==========================================
-- Teacher portal test data (Backend Phase 1, Step 1.1)
-- Two teachers, so ownership can be tested: Teacher A must never see or change Teacher B's data.
-- Rows are linked by unique values (Email, SubjectName) or SCOPE_IDENTITY(), so no identity numbers are hard-coded.
-- ==========================================

-- Teachers (passwords are BCrypt cost-12 hashes, same format as the Admin and Learner rows)
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [ApplicationId])
VALUES ('Bryan Yeong', 'bryanyeong@edu.com.my', '$2a$12$CKfrdV0bSGGst.bMr8A4G.RmmIaI93SA9kx3hrkvmk.V/PulB/SwK', 32, 'Kuala Lumpur, Malaysia', 'Advanced', 'Active', NULL);
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [ApplicationId])
VALUES ('Sarah Lim', 'sarahlim@edu.com.my', '$2a$12$ctWavkUvhh0JdPtUx8H1A.s/tF.pNnBRb8qDhxQDSMnrjrZSw6taW', 29, 'Penang, Malaysia', 'Intermediate', 'Active', NULL);
-- Newly registered teacher with no courses yet (for testing empty states). Password: Newbie1234!
INSERT INTO [dbo].[Teacher] ([Name], [Email], [Password], [Age], [Region], [TeachingLevel], [AccStatus], [ApplicationId])
VALUES ('Nina Tan', 'ninatan@edu.com.my', '$2a$12$.Jve0o18RkIO0nDUO2dgN.Q5o7WUW8GLGlq5s/i2fobHTY1RNZpTu', 26, 'Johor Bahru, Malaysia', 'Beginner', 'Active', NULL);

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
    (DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 1, 'Introduction to Python', 'Get set up with Python, run your first program, and learn how Python code is structured.', '2 hours', NULL, @CourseId, @BryanId),
    (DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -33, GETDATE()), 2, 'Variables and Data Types', 'Understand variables, strings, numbers, booleans, and common type conversions in Python.', '3 hours', NULL, @CourseId, @BryanId),
    (DATEADD(DAY, -36, GETDATE()), DATEADD(DAY, -30, GETDATE()), 3, 'Control Flow', 'Make decisions and repeat work with if statements, for loops, and while loops.', '4 hours', NULL, @CourseId, @BryanId);

-- Course: Java Programming Masterclass (Bryan Yeong)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -30, GETDATE()), 'Java Programming Masterclass', 'Master object-oriented Java, from core syntax and collections to robust application architecture and testing.', 'Hard', '32 hours', @BryanId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'Java'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -50, GETDATE()), 1, 'Java Basics and Syntax', 'Learn the structure of a Java program, primitive types, operators, and basic input and output.', '3 hours', NULL, @CourseId, @BryanId),
    (DATEADD(DAY, -52, GETDATE()), DATEADD(DAY, -45, GETDATE()), 2, 'Object-Oriented Programming', 'Model real problems with classes, objects, inheritance, interfaces, and polymorphism.', '5 hours', NULL, @CourseId, @BryanId);

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
    (DATEADD(DAY, -70, GETDATE()), DATEADD(DAY, -65, GETDATE()), 1, 'Working with Data in Python', 'Load data from files and inspect it with lists, dictionaries, and pandas DataFrames.', '3 hours', NULL, @CourseId, @BryanId),
    (DATEADD(DAY, -68, GETDATE()), DATEADD(DAY, -60, GETDATE()), 2, 'Cleaning and Transforming Data', 'Handle missing values, fix types, filter rows, and reshape data ready for analysis.', '4 hours', NULL, @CourseId, @BryanId),
    (DATEADD(DAY, -66, GETDATE()), DATEADD(DAY, -58, GETDATE()), 3, 'Visualising Results', 'Turn data into clear charts and summaries that answer a question.', '3.5 hours', NULL, @CourseId, @BryanId);

-- Course: C Programming Essentials (Sarah Lim)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -12, GETDATE()), 'C Programming Essentials', 'Learn the fundamentals of C, from variables and control flow to functions, arrays, and pointers.', 'Easy', '20 hours', @SarahId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -20, GETDATE()), 1, 'Introduction to C', 'Get familiar with the C language, its tools, and the structure of a first program.', '2 hours', NULL, @CourseId, @SarahId),
    (DATEADD(DAY, -23, GETDATE()), DATEADD(DAY, -18, GETDATE()), 2, 'Variables and Data Types', 'Understand variables, constants, primitive data types, and type conversions in C.', '3 hours', NULL, @CourseId, @SarahId);

-- Course: C++ Algorithms & Data Structures (Sarah Lim)
INSERT INTO [dbo].[Course] ([DateCreation], [DateUpdate], [CourseTitle], [CourseDescription], [DifficultyLevel], [CourseDuration], [TeacherId])
VALUES (DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -35, GETDATE()), 'C++ Algorithms & Data Structures', 'Develop efficient problem-solving skills with C++ algorithms, data structures, and complexity analysis.', 'Hard', '36 hours', @SarahId);
SET @CourseId = SCOPE_IDENTITY();

INSERT INTO [dbo].[CourseSubject] ([CourseId], [SubjectId])
VALUES (@CourseId, (SELECT [SubjectId] FROM [dbo].[Subject] WHERE [SubjectName] = 'C++'));

INSERT INTO [dbo].[Chapter] ([DateCreation], [DateUpdate], [ChapterNum], [ChapterTitle], [ChapterDescription], [ChapterDuration], [ChapterMediaLink], [CourseId], [TeacherId])
VALUES
    (DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -55, GETDATE()), 1, 'Pointers and Memory', 'Work with pointers, references, and dynamic memory safely and efficiently.', '4 hours', NULL, @CourseId, @SarahId),
    (DATEADD(DAY, -58, GETDATE()), DATEADD(DAY, -50, GETDATE()), 2, 'Arrays and Vectors', 'Store and process collections of data with arrays and the standard vector container.', '3 hours', NULL, @CourseId, @SarahId);

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
    (DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -7, GETDATE()), 1, 'Machine Learning Foundations', 'Understand supervised learning, features, labels, and how models are trained and tested.', '3 hours', NULL, @CourseId, @SarahId),
    (DATEADD(DAY, -9, GETDATE()), DATEADD(DAY, -5, GETDATE()), 2, 'Training Your First Model', 'Fit a simple model, make predictions, and measure how well it performs.', '4 hours', NULL, @CourseId, @SarahId);
