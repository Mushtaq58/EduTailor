--
-- PostgreSQL database dump
--

\restrict z2QuiW8KzWio9G67PdMtNPu4kiLOUH1hUwkLBbNQWiDj4J7jFP9gdMuYUhQqPYd

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookmarks (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    media_type character varying(10) NOT NULL,
    timestamp_sec double precision NOT NULL,
    label character varying(255) DEFAULT ''::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bookmarks OWNER TO postgres;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookmarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bookmarks_id_seq OWNER TO postgres;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bookmarks_id_seq OWNED BY public.bookmarks.id;


--
-- Name: chapters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chapters (
    id integer NOT NULL,
    chapter_number integer NOT NULL,
    title character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.chapters OWNER TO postgres;

--
-- Name: chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chapters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chapters_id_seq OWNER TO postgres;

--
-- Name: chapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chapters_id_seq OWNED BY public.chapters.id;


--
-- Name: content_generation_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.content_generation_log (
    id integer NOT NULL,
    topic_id character varying(10),
    content_type character varying(50) NOT NULL,
    generated_code text,
    preview_path character varying(500),
    status character varying(50) NOT NULL,
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.content_generation_log OWNER TO postgres;

--
-- Name: content_generation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.content_generation_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.content_generation_log_id_seq OWNER TO postgres;

--
-- Name: content_generation_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.content_generation_log_id_seq OWNED BY public.content_generation_log.id;


--
-- Name: content_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.content_status (
    id integer NOT NULL,
    topic_id character varying(10),
    content_type character varying(50) NOT NULL,
    status character varying(50) NOT NULL,
    file_path character varying(500),
    generated_at timestamp without time zone,
    approved_by integer,
    approved_at timestamp without time zone
);


ALTER TABLE public.content_status OWNER TO postgres;

--
-- Name: content_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.content_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.content_status_id_seq OWNER TO postgres;

--
-- Name: content_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.content_status_id_seq OWNED BY public.content_status.id;


--
-- Name: feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feedback (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    rating integer,
    feedback_text text,
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.feedback OWNER TO postgres;

--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feedback_id_seq OWNER TO postgres;

--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;


--
-- Name: format_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.format_tracking (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    format character varying(20) NOT NULL,
    time_spent_seconds integer DEFAULT 0,
    session_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    quiz_score_after integer,
    CONSTRAINT format_tracking_format_check CHECK (((format)::text = ANY ((ARRAY['english'::character varying, 'urdu'::character varying, 'audio_en'::character varying, 'visual'::character varying, 'lecture'::character varying])::text[])))
);


ALTER TABLE public.format_tracking OWNER TO postgres;

--
-- Name: format_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.format_tracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.format_tracking_id_seq OWNER TO postgres;

--
-- Name: format_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.format_tracking_id_seq OWNED BY public.format_tracking.id;


--
-- Name: highlights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.highlights (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    tab character varying(20) NOT NULL,
    selected_text text NOT NULL,
    color character varying(20) DEFAULT 'yellow'::character varying,
    paragraph_index integer NOT NULL,
    start_offset integer NOT NULL,
    end_offset integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.highlights OWNER TO postgres;

--
-- Name: highlights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.highlights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.highlights_id_seq OWNER TO postgres;

--
-- Name: highlights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.highlights_id_seq OWNED BY public.highlights.id;


--
-- Name: lecture_slides; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lecture_slides (
    id integer NOT NULL,
    topic_id character varying(10) NOT NULL,
    slide_number integer NOT NULL,
    title character varying(255) NOT NULL,
    bullets jsonb NOT NULL,
    narration_ur text,
    audio_ur_path character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lecture_slides OWNER TO postgres;

--
-- Name: lecture_slides_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lecture_slides_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lecture_slides_id_seq OWNER TO postgres;

--
-- Name: lecture_slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lecture_slides_id_seq OWNED BY public.lecture_slides.id;


--
-- Name: note_clips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.note_clips (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    source character varying(30) NOT NULL,
    content text NOT NULL,
    slide_number integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.note_clips OWNER TO postgres;

--
-- Name: note_clips_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.note_clips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.note_clips_id_seq OWNER TO postgres;

--
-- Name: note_clips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.note_clips_id_seq OWNED BY public.note_clips.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    content text DEFAULT ''::text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notes OWNER TO postgres;

--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notes_id_seq OWNER TO postgres;

--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: otp_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.otp_verifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    otp_code character varying(6) NOT NULL,
    purpose character varying(50) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.otp_verifications OWNER TO postgres;

--
-- Name: otp_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.otp_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.otp_verifications_id_seq OWNER TO postgres;

--
-- Name: otp_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otp_verifications_id_seq OWNED BY public.otp_verifications.id;


--
-- Name: question_performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_performance (
    id integer NOT NULL,
    quiz_attempt_id integer,
    user_id integer,
    topic_id character varying(10),
    question_type character varying(20),
    question_text text,
    student_answer text,
    correct_answer text,
    reference_answer text,
    is_correct boolean,
    similarity_score double precision,
    points_earned integer,
    points_possible integer,
    answered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.question_performance OWNER TO postgres;

--
-- Name: question_performance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.question_performance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.question_performance_id_seq OWNER TO postgres;

--
-- Name: question_performance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.question_performance_id_seq OWNED BY public.question_performance.id;


--
-- Name: quiz_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_attempts (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    format_used character varying(50) NOT NULL,
    mcq_score integer NOT NULL,
    subjective_score integer NOT NULL,
    total_score integer NOT NULL,
    mcq_responses jsonb,
    subjective_responses jsonb,
    time_spent_learning_seconds integer,
    quiz_duration_seconds integer,
    attempted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.quiz_attempts OWNER TO postgres;

--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quiz_attempts_id_seq OWNER TO postgres;

--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_attempts_id_seq OWNED BY public.quiz_attempts.id;


--
-- Name: student_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_progress (
    user_id integer NOT NULL,
    topic_id character varying(10) NOT NULL,
    status character varying(50) DEFAULT 'not_started'::character varying NOT NULL,
    best_score integer,
    attempts_count integer DEFAULT 0,
    time_spent_seconds integer DEFAULT 0,
    last_accessed timestamp without time zone,
    completed_at timestamp without time zone
);


ALTER TABLE public.student_progress OWNER TO postgres;

--
-- Name: student_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_questions (
    id integer NOT NULL,
    user_id integer,
    topic_id character varying(10),
    question_text text NOT NULL,
    answer_text text,
    citation character varying(500),
    was_helpful boolean,
    asked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_questions OWNER TO postgres;

--
-- Name: student_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_questions_id_seq OWNER TO postgres;

--
-- Name: student_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_questions_id_seq OWNED BY public.student_questions.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topics (
    topic_id character varying(10) NOT NULL,
    chapter_id integer,
    topic_name character varying(255) NOT NULL,
    paragraph_1 text NOT NULL,
    paragraph_2 text NOT NULL,
    paragraph_3 text,
    paragraph_4 text,
    paragraph_5 text,
    visual_type character varying(20),
    visual_path character varying(500),
    visual_narration text,
    urdu_paragraph_1 text,
    urdu_paragraph_2 text,
    urdu_paragraph_3 text,
    urdu_paragraph_4 text,
    urdu_paragraph_5 text,
    audio_en_path character varying(500),
    mindmap_json jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT topics_visual_type_check CHECK (((visual_type)::text = ANY ((ARRAY['animation'::character varying, 'diagram'::character varying])::text[])))
);


ALTER TABLE public.topics OWNER TO postgres;

--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_preferences (
    user_id integer NOT NULL,
    current_format character varying(50),
    recommended_format character varying(50),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_preferences OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    is_verified boolean DEFAULT false,
    profile_picture_url character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['student'::character varying, 'teacher'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vark_assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vark_assessments (
    id integer NOT NULL,
    user_id integer,
    visual_score integer NOT NULL,
    auditory_score integer NOT NULL,
    reading_score integer NOT NULL,
    kinesthetic_score integer NOT NULL,
    recommended_format character varying(50) NOT NULL,
    assessed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vark_assessments OWNER TO postgres;

--
-- Name: vark_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vark_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vark_assessments_id_seq OWNER TO postgres;

--
-- Name: vark_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vark_assessments_id_seq OWNED BY public.vark_assessments.id;


--
-- Name: bookmarks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks ALTER COLUMN id SET DEFAULT nextval('public.bookmarks_id_seq'::regclass);


--
-- Name: chapters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chapters ALTER COLUMN id SET DEFAULT nextval('public.chapters_id_seq'::regclass);


--
-- Name: content_generation_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_generation_log ALTER COLUMN id SET DEFAULT nextval('public.content_generation_log_id_seq'::regclass);


--
-- Name: content_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_status ALTER COLUMN id SET DEFAULT nextval('public.content_status_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);


--
-- Name: format_tracking id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format_tracking ALTER COLUMN id SET DEFAULT nextval('public.format_tracking_id_seq'::regclass);


--
-- Name: highlights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.highlights ALTER COLUMN id SET DEFAULT nextval('public.highlights_id_seq'::regclass);


--
-- Name: lecture_slides id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecture_slides ALTER COLUMN id SET DEFAULT nextval('public.lecture_slides_id_seq'::regclass);


--
-- Name: note_clips id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note_clips ALTER COLUMN id SET DEFAULT nextval('public.note_clips_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: otp_verifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otp_verifications ALTER COLUMN id SET DEFAULT nextval('public.otp_verifications_id_seq'::regclass);


--
-- Name: question_performance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_performance ALTER COLUMN id SET DEFAULT nextval('public.question_performance_id_seq'::regclass);


--
-- Name: quiz_attempts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts ALTER COLUMN id SET DEFAULT nextval('public.quiz_attempts_id_seq'::regclass);


--
-- Name: student_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_questions ALTER COLUMN id SET DEFAULT nextval('public.student_questions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vark_assessments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vark_assessments ALTER COLUMN id SET DEFAULT nextval('public.vark_assessments_id_seq'::regclass);


--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookmarks (id, user_id, topic_id, media_type, timestamp_sec, label, created_at) FROM stdin;
2	5	1.1	audio	45.147583	Testing Bookmark 1. Definition Starts here.	2026-04-24 18:34:36.662618
4	5	1.1	video	28.93814	Testing Video Bookmark 1: Electron Transfer Process	2026-04-24 18:36:14.568352
\.


--
-- Data for Name: chapters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chapters (id, chapter_number, title, description) FROM stdin;
1	1	Chemical Bonding	Understanding how atoms form bonds and the different types of chemical bonds
2	2	Atomic Structure	The structure of atoms, subatomic particles, isotopes, and electronic configuration
3	3	States of Matter	Properties of solids, liquids and gases, changes of state, diffusion, and gas laws
4	4	Chemical Reactions	Types of reactions, energy changes, reaction rates, redox, electrolysis, and equilibrium
5	5	Acids, Bases and Salts	Properties of acids and bases, the pH scale, neutralization, and preparation of salts
\.


--
-- Data for Name: content_generation_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.content_generation_log (id, topic_id, content_type, generated_code, preview_path, status, generated_at) FROM stdin;
\.


--
-- Data for Name: content_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.content_status (id, topic_id, content_type, status, file_path, generated_at, approved_by, approved_at) FROM stdin;
1	1.1	urdu	approved	\N	2026-04-17 15:22:29.375544	3	2026-04-17 15:22:43.564144
2	1.1	audio_en	approved	/api/media/audio/1.1_en.mp3	2026-04-17 15:22:49.567538	3	2026-04-17 15:23:26.899743
3	1.1	animation	approved	/api/media/animations/1.1_animation.mp4	2026-04-18 07:14:39.753285	3	2026-04-18 07:27:47.997971
4	1.1	visual_narration	approved	\N	2026-04-18 07:14:39.753285	3	2026-04-18 07:27:53.376631
15	1.2	animation	approved	/api/media/animations/1.2_animation.mp4	2026-04-18 07:28:06.276285	3	2026-04-18 07:32:05.227432
16	1.2	visual_narration	approved	\N	2026-04-18 07:28:06.276285	3	2026-04-18 07:32:07.449339
77	3.1	lecture	pending_review	\N	2026-04-22 16:50:20.90208	\N	\N
78	3.1	mindmap	pending_review	\N	2026-04-22 16:50:20.90208	\N	\N
36	1.5	visual_narration	approved	\N	2026-04-18 07:33:16.335515	3	2026-04-18 07:34:02.757073
35	1.5	diagram	approved	/api/media/diagrams/1.5_diagram.png	2026-04-18 07:33:16.335515	3	2026-04-18 07:34:03.874961
41	1.4	animation	approved	/api/media/animations/1.4_animation.mp4	2026-04-18 08:02:30.015784	3	2026-04-18 08:09:25.527254
42	1.4	visual_narration	approved	\N	2026-04-18 08:02:30.015784	3	2026-04-18 08:09:27.112469
44	1.3	visual_narration	approved	\N	2026-04-18 08:13:33.120185	3	2026-04-18 08:17:32.573566
43	1.3	animation	approved	/api/media/animations/1.3_animation.mp4	2026-04-18 08:13:33.120185	3	2026-04-18 08:17:33.833083
45	4.5	animation	approved	/api/media/animations/4.5_animation.mp4	2026-04-18 08:26:48.281086	3	2026-04-18 08:31:13.322824
46	4.5	visual_narration	approved	\N	2026-04-18 08:26:48.281086	3	2026-04-18 08:31:15.364554
49	4.5	urdu	approved	\N	2026-04-18 08:40:04.959607	3	2026-04-18 08:40:16.211706
50	4.5	audio_en	approved	/api/media/audio/4.5_en.mp3	2026-04-18 08:40:18.378822	3	2026-04-18 08:40:45.885818
51	1.6	animation	approved	/api/media/animations/1.6_animation.mp4	2026-04-18 09:04:41.512922	3	2026-04-18 09:10:25.962631
52	1.6	visual_narration	approved	\N	2026-04-18 09:04:41.512922	3	2026-04-18 09:10:27.733375
53	2.1	animation	approved	/api/media/animations/2.1_animation.mp4	2026-04-19 06:16:19.148487	3	2026-04-19 06:23:24.804713
54	2.1	visual_narration	approved	\N	2026-04-19 06:16:19.148487	3	2026-04-19 06:23:27.592925
79	3.1	urdu	approved	\N	2026-04-22 16:54:11.227099	3	2026-04-22 16:54:36.4835
55	1.1	lecture	approved	\N	2026-04-19 10:54:58.900119	\N	\N
56	1.1	mindmap	approved	\N	2026-04-19 10:54:58.900119	\N	\N
61	1.2	lecture	approved	\N	2026-04-19 11:50:26.735933	\N	\N
62	1.2	mindmap	approved	\N	2026-04-19 11:50:26.735933	\N	\N
63	1.3	urdu	approved	\N	2026-04-19 12:50:08.713556	3	2026-04-19 12:50:36.059844
65	1.3	lecture	approved	\N	2026-04-19 12:54:59.746317	\N	\N
66	1.3	mindmap	approved	\N	2026-04-19 12:54:59.746317	\N	\N
64	1.3	audio_en	approved	/api/media/audio/1.3_en.mp3	2026-04-19 12:50:39.980999	3	2026-04-19 12:55:23.591064
67	1.4	urdu	approved	\N	2026-04-19 13:59:51.237629	3	2026-04-19 14:00:01.930421
68	1.4	audio_en	approved	/api/media/audio/1.4_en.mp3	2026-04-19 14:00:08.009903	3	2026-04-19 14:00:31.755485
69	1.4	lecture	pending_review	\N	2026-04-19 14:08:03.72839	\N	\N
70	1.4	mindmap	pending_review	\N	2026-04-19 14:08:03.72839	\N	\N
71	1.5	urdu	approved	\N	2026-04-19 14:56:42.054446	3	2026-04-19 14:56:49.87435
72	1.5	audio_en	approved	/api/media/audio/1.5_en.mp3	2026-04-19 14:56:52.122909	3	2026-04-19 14:57:23.890799
73	1.5	lecture	pending_review	\N	2026-04-19 15:08:40.552645	\N	\N
74	1.5	mindmap	pending_review	\N	2026-04-19 15:08:40.552645	\N	\N
75	4.5	lecture	pending_review	\N	2026-04-19 16:50:26.93616	\N	\N
76	4.5	mindmap	pending_review	\N	2026-04-19 16:50:26.93616	\N	\N
80	3.1	audio_en	approved	/api/media/audio/3.1_en.mp3	2026-04-22 16:54:18.408133	3	2026-04-22 16:54:47.334211
81	3.1	animation	approved	/api/media/animations/3.1_animation.mp4	2026-04-22 16:54:51.674149	3	2026-04-22 17:00:04.896247
82	3.1	visual_narration	approved	\N	2026-04-22 16:54:51.674149	3	2026-04-22 17:00:06.588588
83	2.3	urdu	approved	\N	2026-04-22 17:10:51.256489	3	2026-04-22 17:11:15.814866
84	2.3	audio_en	approved	/api/media/audio/2.3_en.mp3	2026-04-22 17:10:53.625136	3	2026-04-22 17:11:19.931711
85	2.3	lecture	pending_review	\N	2026-04-22 17:19:48.195469	\N	\N
86	2.3	mindmap	pending_review	\N	2026-04-22 17:19:48.195469	\N	\N
87	3.2	urdu	approved	\N	2026-04-22 17:49:10.253268	3	2026-04-22 17:49:20.721488
88	3.2	audio_en	approved	/api/media/audio/3.2_en.mp3	2026-04-22 17:49:22.129192	3	2026-04-22 17:50:10.387161
89	3.2	animation	approved	/api/media/animations/3.2_animation.mp4	2026-04-22 17:49:45.736715	3	2026-04-22 17:54:24.384218
90	3.2	visual_narration	approved	\N	2026-04-22 17:49:45.736715	3	2026-04-22 17:54:26.320643
91	3.2	lecture	pending_review	\N	2026-04-22 18:03:18.516113	\N	\N
92	3.2	mindmap	pending_review	\N	2026-04-22 18:03:18.516113	\N	\N
93	3.3	urdu	approved	\N	2026-04-22 18:13:14.239123	3	2026-04-22 18:13:30.417112
94	3.3	audio_en	approved	/api/media/audio/3.3_en.mp3	2026-04-22 18:13:31.506847	3	2026-04-22 18:13:49.401676
95	3.3	animation	approved	/api/media/animations/3.3_animation.mp4	2026-04-22 18:13:51.765446	3	2026-04-22 18:16:11.770653
96	3.3	visual_narration	approved	\N	2026-04-22 18:13:51.765446	3	2026-04-22 18:16:15.043807
97	3.3	lecture	pending_review	\N	2026-04-22 18:22:26.165063	\N	\N
98	3.3	mindmap	pending_review	\N	2026-04-22 18:22:26.165063	\N	\N
99	4.3	animation	pending_review	/api/media/animations/4.3_animation.mp4	2026-04-23 20:06:44.539546	\N	\N
100	4.3	visual_narration	pending_review	\N	2026-04-23 20:06:44.539546	\N	\N
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feedback (id, user_id, topic_id, rating, feedback_text, submitted_at) FROM stdin;
1	5	1.1	5	Testing Reviews.	2026-04-24 20:37:52.293812
\.


--
-- Data for Name: format_tracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.format_tracking (id, user_id, topic_id, format, time_spent_seconds, session_date, quiz_score_after) FROM stdin;
2	5	2.1	urdu	2	2026-04-17 14:32:56.302622	\N
1	5	2.1	english	11	2026-04-17 14:32:53.943322	\N
3	5	1.6	english	5	2026-04-17 15:21:08.284648	\N
4	5	2.2	english	3	2026-04-17 15:21:44.866131	\N
7	5	5.2	urdu	2	2026-04-18 06:17:42.493115	\N
8	5	1.1	urdu	2	2026-04-18 07:34:31.308735	\N
9	5	1.1	audio_en	7	2026-04-18 07:34:38.151274	\N
5	5	1.1	english	17	2026-04-18 06:14:39.474203	32
11	5	4.5	audio_en	5	2026-04-18 08:42:41.756402	\N
13	5	4.5	urdu	10	2026-04-18 08:42:54.38563	\N
10	5	4.5	visual	314	2026-04-18 08:35:04.153596	\N
12	5	4.5	english	157	2026-04-18 08:42:44.188448	\N
6	5	5.2	english	182	2026-04-18 06:17:40.43684	\N
14	5	1.2	english	4	2026-04-18 09:20:22.888505	\N
15	5	1.2	urdu	4	2026-04-18 09:20:26.545324	\N
16	5	1.2	visual	2	2026-04-18 09:20:30.50424	94
19	5	2.1	urdu	3	2026-04-19 06:26:27.605291	\N
18	5	2.1	visual	31	2026-04-19 06:24:30.581721	\N
44	5	4.5	urdu	57	2026-04-19 18:47:15.769321	\N
17	5	2.1	english	191	2026-04-19 06:24:01.901162	\N
20	5	4.6	english	85	2026-04-19 06:32:33.100498	\N
22	5	1.1	urdu	2	2026-04-19 11:01:58.054526	\N
40	5	4.5	lecture	2293	2026-04-19 16:51:55.667542	\N
42	5	4.5	visual	331	2026-04-19 18:21:36.228475	\N
24	5	1.2	visual	2	2026-04-19 11:51:43.467247	\N
25	5	1.2	urdu	3	2026-04-19 11:56:55.317811	\N
26	5	1.2	english	5	2026-04-19 11:57:00.133981	\N
27	5	1.1	audio_en	6	2026-04-19 12:19:09.552339	\N
41	5	4.5	english	157	2026-04-19 17:08:43.648935	\N
31	5	1.3	visual	4	2026-04-19 12:59:26.924187	\N
46	5	1.1	lecture	4	2026-04-22 16:35:26.760888	\N
32	5	1.3	audio_en	6	2026-04-19 13:01:56.990819	\N
45	5	1.1	english	81	2026-04-22 16:35:22.83976	\N
28	5	1.3	english	6	2026-04-19 12:40:02.071558	\N
30	5	1.3	lecture	362	2026-04-19 12:57:12.158085	\N
33	5	1.4	audio_en	2	2026-04-19 14:09:48.878494	\N
34	5	1.4	lecture	770	2026-04-19 14:22:40.591001	\N
36	5	1.5	urdu	4	2026-04-19 15:13:50.819151	\N
37	5	1.5	audio_en	3	2026-04-19 15:13:53.600067	\N
38	5	1.5	visual	3	2026-04-19 15:13:56.287333	\N
35	5	1.5	english	13	2026-04-19 15:13:47.047001	\N
39	5	1.5	lecture	569	2026-04-19 15:14:50.529768	\N
21	5	1.1	english	327	2026-04-19 10:49:18.653168	\N
48	5	3.1	lecture	55	2026-04-22 16:50:32.137493	\N
23	5	1.1	visual	16	2026-04-19 11:02:02.55903	\N
29	5	1.1	lecture	66	2026-04-19 12:40:16.596313	\N
47	5	3.1	english	42	2026-04-22 16:50:29.858459	\N
49	5	2.3	lecture	34	2026-04-22 17:21:56.055346	\N
50	5	3.2	english	2	2026-04-22 18:04:31.612492	\N
51	5	3.2	audio_en	15	2026-04-22 18:04:48.481868	\N
52	5	3.2	visual	2	2026-04-22 18:04:50.606739	\N
53	5	3.3	lecture	113	2026-04-22 18:23:25.603585	\N
54	5	1.4	lecture	229	2026-04-22 18:29:12.515248	\N
55	5	1.4	visual	110	2026-04-22 18:32:45.22109	\N
56	5	1.4	audio_en	8	2026-04-22 18:32:52.790146	\N
57	5	1.4	urdu	16	2026-04-22 18:33:09.31395	\N
58	5	1.4	english	9	2026-04-22 18:33:16.476133	\N
59	5	1.4	english	7	2026-04-23 19:37:36.076094	\N
73	5	1.1	audio_en	121	2026-04-24 18:35:07.130753	\N
60	5	1.4	urdu	2	2026-04-23 19:37:38.122144	\N
43	5	4.5	audio_en	61	2026-04-19 18:37:59.868612	\N
61	5	1.4	visual	269	2026-04-23 19:42:07.82204	\N
62	5	1.4	lecture	157	2026-04-23 19:44:24.369879	\N
75	5	1.1	lecture	126	2026-04-24 18:39:13.802667	\N
72	5	1.1	english	291	2026-04-24 18:30:37.690406	\N
76	5	1.1	urdu	20	2026-04-24 18:55:49.643973	20
63	5	1.1	english	351	2026-04-23 19:46:04.626093	\N
66	5	1.1	visual	114	2026-04-23 20:00:38.430351	\N
64	5	1.1	lecture	87	2026-04-23 19:46:07.253099	20
65	5	1.1	audio_en	4	2026-04-23 19:48:14.526565	\N
67	5	1.1	urdu	8	2026-04-23 20:02:14.829021	\N
68	5	1.4	lecture	4	2026-04-24 17:53:34.347396	\N
69	5	1.4	visual	8	2026-04-24 17:53:42.755016	\N
71	5	1.4	urdu	11	2026-04-24 17:54:48.843147	\N
70	5	1.4	english	352	2026-04-24 17:54:24.297372	\N
74	5	1.1	visual	153	2026-04-24 18:36:43.879359	\N
\.


--
-- Data for Name: highlights; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.highlights (id, user_id, topic_id, tab, selected_text, color, paragraph_index, start_offset, end_offset, created_at) FROM stdin;
11	5	1.1	english	The metal atom loses electrons to become a positively charged cation, while the non-metal gains these electrons to become a negatively charged anion.	pink	0	242	391	2026-04-24 18:32:14.827906
\.


--
-- Data for Name: lecture_slides; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecture_slides (id, topic_id, slide_number, title, bullets, narration_ur, audio_ur_path, created_at) FROM stdin;
13	1.1	1	What is an Ionic Bond?	["Ionic bond forms through electrostatic attraction between oppositely charged ions", "Electrons are transferred from one atom to another", "Metal atoms lose electrons (cation), non-metals gain electrons (anion)", "Strong electrostatic force holds ions together in ionic compounds"]	[enthusiasm] Dekho bachon, aaj hum ionic bonding ki baat karenge! [interest] Ionic bond ek aisi chemical bond hai jo oppositely charged ions ke beech electrostatic attraction se banti hai. [serious] Yahan pe electrons transfer hote hain ek atom se doosre atom tak - bilkul jaise ghar mein bari behan apni choti behan ko dupatta de deti hai. [cheerful] Metal atoms apne electrons lose kar dete hain aur positively charged cation ban jate hain, jabke non-metal atoms un electrons ko gain karke negatively charged anion ban jate hain. [soft] Phir in opposite charges ke beech strong electrostatic force attraction hoti hai jo unhe ionic compound mein bind karke rakhti hai.	media/lectures/1_1_slide_1.mp3	2026-04-19 10:52:38.79375
14	1.1	2	Why Metals and Non-Metals Form Ionic Bonds	["Metals have low ionization energy and readily lose valence electrons", "Non-metals have high electron affinity and readily gain electrons", "Large difference in electronegativity between metals and non-metals", "Both atoms achieve stable noble gas electron configuration"]	[interest] Ab sawal ye hai ke ionic bonding metals aur non-metals ke beech hi kyun hoti hai? [serious] Dekho, metals jaise sodium ka ionization energy bohot kam hota hai, so ye apne valence electrons asani se lose kar dete hain. [enthusiasm] Non-metals jaise chlorine ka electron affinity high hota hai, matlab ye electrons ko gain karna chahte hain! [cheerful] Bilkul jaise bazaar mein ek dukandaar apna maal bechna chahta hai aur doosra customer kharedna chahta hai - perfect match! [soft] Dono atoms ka electronegativity mein bara difference hota hai aur dono stable noble gas configuration achieve karna chahte hain.	media/lectures/1_1_slide_2.mp3	2026-04-19 10:52:38.79375
15	1.1	3	Formation of Sodium Chloride (NaCl)	["Sodium has 1 valence electron, chlorine has 7 valence electrons", "Sodium loses 1 electron to become Na⁺ cation", "Chlorine gains 1 electron to become Cl⁻ anion", "Both achieve stable octet configuration like noble gases"]	[enthusiasm] Chalo ab ek example se samajhte hain sodium chloride yaani table salt! [interest] Sodium atom ke paas sirf 1 valence electron hai jabke chlorine ke paas 7 valence electrons hain. [short pause] Sodium apna 1 electron chlorine ko de deta hai aur Na⁺ cation ban jata hai - bilkul jaise ek dost doosre dost ko baarish mein umbrella share karta hai! [cheerful] Chlorine us electron ko gain karke Cl⁻ anion ban jata hai. [soft] Is tarah dono atoms stable octet configuration achieve kar lete hain, jaise noble gases ka hota hai, aur ye bohot stable state hai.	media/lectures/1_1_slide_3.mp3	2026-04-19 10:52:38.79375
16	1.1	4	Properties: Melting and Boiling Points	["Ionic compounds have high melting and boiling points", "Strong electrostatic forces between ions require significant energy to overcome", "Crystal lattice structure makes them hard and brittle", "Examples: NaCl melts at 801°C, MgO melts at 2852°C"]	[serious] Ab hum ionic compounds ki properties dekhenge jo exam mein bohot important hain! [enthusiasm] Ionic compounds ka melting point aur boiling point bohot zyada high hota hai. [interest] Kyunki ions ke beech jo electrostatic forces hain wo bohot strong hain, unhe todne ke liye bohot zyada energy chahiye - jaise ghar ki roti ko haath se todna mushkil hota hai agar wo sakhti se bani ho! [short pause] Crystal lattice structure ki wajah se ye hard aur brittle hote hain. [cheerful] Example ke liye, sodium chloride 801°C pe melt hota hai aur magnesium oxide to 2852°C pe!	media/lectures/1_1_slide_4.mp3	2026-04-19 10:52:38.79375
17	1.1	5	Electrical Conductivity of Ionic Compounds	["Solid ionic compounds do not conduct electricity", "Ions are fixed in position within crystal lattice structure", "When melted or dissolved in water, ions become mobile", "Mobile ions can carry electric current and conduct electricity"]	[interest] Bachon, electrical conductivity ki property bohot interesting hai! [serious] Jab ionic compound solid form mein hota hai to ye electricity conduct nahi karta. [soft] Kyunki ions crystal lattice mein fixed position pe hote hain, wo move nahi kar sakte - bilkul jaise bijli ka connection wire ke andar hi rahta hai. [enthusiasm] Lekin jab hum inhe melt kar dein ya paani mein dissolve kar dein, to ions mobile ho jate hain! [cheerful] Ab ye ions idhar udhar move kar sakte hain aur electric current carry kar sakte hain, so ab ye electricity conduct karte hain - jaise mobile phone charging mein current flow hota hai!	media/lectures/1_1_slide_5.mp3	2026-04-19 10:52:38.79375
18	1.1	6	Crystal Lattice Structure	["Ions arrange in regular, repeating 3D pattern", "Structure maximizes attractive forces and minimizes repulsive forces", "Creates strong and rigid structure", "Each positive ion is surrounded by negative ions and vice versa"]	[enthusiasm] Ab dekhte hain crystal lattice structure kya hoti hai! [interest] Ionic compounds mein ions apne aap ko ek regular, repeating three-dimensional pattern mein arrange karte hain. [serious] Ye arrangement is tarah hota hai ke attractive forces maximum ho jayein aur repulsive forces minimum - bilkul jaise cricket team mein players apni positions strategically lete hain! [cheerful] Is se ek bohot strong aur rigid structure banta hai. [soft] Har positive ion negative ions se ghira hota hai aur har negative ion positive ions se ghira hota hai, perfect balance!	media/lectures/1_1_slide_6.mp3	2026-04-19 10:52:38.79375
19	1.1	7	Lattice Energy and Bond Strength	["Lattice energy is energy required to separate ionic solid into gaseous ions", "Measures the strength of ionic bonds in the compound", "Smaller ions and higher charges produce greater lattice energy", "Higher lattice energy means higher melting and boiling points"]	[serious] Lattice energy ek bohot important concept hai jo exam mein zaroor aata hai! [interest] Lattice energy wo energy hai jo chahiye ek mole ionic solid ko separate karke gaseous ions banana ke liye. [short pause] Ye actually ionic bonds ki strength measure karta hai - jaise chai ke cup ko garam karne mein kitni energy lagti hai! [enthusiasm] Agar ions chote hain aur unki charges zyada hain to lattice energy bara hoga. [cheerful] Aur jis compound ki lattice energy zyada hogi, uska melting point aur boiling point bhi bohot zyada hoga, wo bohot strongly bonded hoga!	\N	2026-04-19 10:52:38.79375
20	1.1	8	Common Examples of Ionic Compounds	["Sodium chloride (NaCl) - table salt used in cooking", "Magnesium oxide (MgO) - used in medicine and construction", "Calcium chloride (CaCl₂) - used as de-icer and drying agent", "All show typical ionic compound properties"]	[cheerful] Chalo ab kuch common examples dekhte hain jo hum daily life mein use karte hain! [enthusiasm] Sodium chloride yaani NaCl wo table salt hai jo hum ghar mein khane mein use karte hain - har roti pe daala jata hai! [interest] Magnesium oxide yaani MgO medicine aur construction mein use hota hai. [soft] Calcium chloride CaCl₂ ko de-icer ke taur pe istemaal karte hain aur drying agent bhi banate hain. [serious] In sab compounds mein typical ionic properties hoti hain jo humne seekhi hain - high melting points, electrical conductivity when dissolved, aur crystal lattice structure!	media/lectures/1_1_slide_8.mp3	2026-04-19 10:52:38.79375
21	1.2	1	What is Covalent Bonding?	["Covalent bond forms when atoms share electron pairs", "Occurs between non-metal atoms with similar electronegativity", "Shared electrons attracted to both nuclei creating strong bond", "Different from ionic bonding where electrons transfer"]	[enthusiasm] Bachon, aaj hum covalent bonding ke baare mein seekhenge! [interest] Dekho, covalent bond tab banta hai jab do atoms apas mein electron pairs share karte hain, bilkul jaise do dost baarish mein aik umbrella share karte hain. [serious] Yeh bonding non-metal atoms ke darmiyan hoti hai jinki electronegativity similar hoti hai. [soft] Shared electrons dono atoms ke nuclei ki taraf attract hote hain aur isse aik strong bond ban jata hai. [short pause] Ionic bonding mein electrons transfer hote hain, lekin covalent bonding mein mutual sharing hoti hai.	media/lectures/1_2_slide_1.mp3	2026-04-19 11:49:02.171584
22	1.2	2	Bonding and Non-Bonding Electron Pairs	["Shared electron pairs called bonding pairs", "Unshared electrons called lone pairs or non-bonding pairs", "Both types of electrons important in molecular structure", "Bonding pairs hold atoms together in molecules"]	[cheerful] Acha bachon, electrons ki do main types hain molecule mein. [enthusiasm] Jab electrons share hote hain do atoms ke darmiyan, to unhe bonding pairs kehte hain - yeh atoms ko aik saath hold karte hain. [interest] Lekin kuch electrons share nahi hote, yeh lone pairs ya non-bonding pairs kehlate hain, jaise mobile phone charge karte waqt extra battery backup. [serious] Dono types ke electrons molecular structure ke liye bohot important hain. [soft] Bonding pairs hi woh connection hain jo molecule ko aik saath rakhte hain.	media/lectures/1_2_slide_2.mp3	2026-04-19 11:49:02.171584
23	1.2	3	Types of Covalent Bonds	["Single bond: one pair of electrons shared (H₂)", "Double bond: two pairs of electrons shared (O₂)", "Triple bond: three pairs of electrons shared (N₂)", "More shared pairs = shorter and stronger bond"]	[enthusiasm] Dekho bachon, covalent bonds teen types ke hote hain! [interest] Single bond mein sirf aik pair share hota hai jaise hydrogen gas H₂ mein, double bond mein do pairs jaise oxygen O₂ mein, aur triple bond mein teen pairs jaise nitrogen N₂ mein. [serious] Jitne zyada electron pairs share honge, bond utna hi shorter aur stronger hoga, bilkul jaise do siblings jitni zyada rotiyan share karein utna strong bond. [soft] Triple bond ko break karne ke liye sabse zyada energy chahiye hoti hai.	media/lectures/1_2_slide_3.mp3	2026-04-19 11:49:02.171584
24	1.2	4	Properties of Covalent Compounds	["Lower melting and boiling points than ionic compounds", "Do not conduct electricity (no free ions)", "Soluble in non-polar solvents, mostly insoluble in water", "Weak intermolecular forces between molecules"]	[serious] Bachon, covalent compounds ke properties ionic compounds se bohot different hain. [interest] Inke melting aur boiling points kam hote hain kyunki intermolecular forces weak hote hain, jaise bijli ka loose connection. [enthusiasm] Yeh electricity conduct nahi karte, chahe pani mein dissolve bhi kar do, kyunki ions nahi bante. [soft] Covalent compounds non-polar solvents mein dissolve hote hain lekin pani mein mostly insoluble hote hain. [short pause] Yeh sab intermolecular forces ke weak hone ki wajah se hota hai.	media/lectures/1_2_slide_4.mp3	2026-04-19 11:49:02.171584
25	1.2	5	Common Examples of Covalent Compounds	["Water (H₂O) - essential for life", "Methane (CH₄) - natural gas used for cooking", "Carbon dioxide (CO₂) - produced in respiration", "Ammonia (NH₃) - used in fertilizers"]	[cheerful] Chaliye ab kuch common examples dekhte hain jo aapke daily life mein milte hain! [enthusiasm] Water H₂O to sab jante hain, yeh covalent compound hai aur life ke liye essential hai. [interest] Methane CH₄ jo aapke ghar mein chai banane ke liye use hoti hai, yeh bhi covalent compound hai. [soft] Carbon dioxide CO₂ jo hum saans lete waqt produce karte hain, aur ammonia NH₃ jo fertilizers mein use hota hai. [laughs] Dekha, kitne familiar examples hain apne aas paas!	media/lectures/1_2_slide_5.mp3	2026-04-19 11:49:02.171584
26	1.2	6	Molecular Geometry and Lewis Structures	["Molecular geometry affects physical and chemical properties", "Water's bent shape gives it unique properties", "Lewis structures show valence electrons as dots", "Help predict molecular shapes and chemical behavior"]	[serious] Bachon, molecular geometry yani atoms ki arrangement bohot important hai. [interest] Water molecule ki bent shape usko unique properties deti hai, bilkul jaise cricket team mein har player ki apni position hoti hai. [enthusiasm] Lewis structures aise diagrams hain jo valence electrons ko dots ki tarah show karte hain aur bonding pairs ko lines se. [soft] Yeh diagrams humein molecular shapes predict karne mein aur chemical behavior samajhne mein madad karte hain. [short pause] Chemistry mein geometry ka role bahut bada hai bachon!	\N	2026-04-19 11:49:02.171584
27	1.3	1	What is Metallic Bonding?	["Chemical bonding that holds metal atoms together", "Metal atoms release their outermost valence electrons", "Creates lattice of positive ions in sea of delocalized electrons", "Strong electrostatic attraction between ions and electrons"]	[enthusiasm] Dekho bachon, aaj hum metallic bonding ke baare mein seekhenge! [soft] Metallic bonding wo chemical bonding hai jo metal atoms ko ek saath hold karti hai solid metal mein. [interest] Ab yahan interesting baat ye hai ke har metal atom apne outermost valence electrons ko release kar deta hai, bilkul aise jaise cricket team mein sab players apni individual performance team ke liye dete hain. [serious] Yeh electrons free ho jaate hain aur poore metal structure mein move karte hain - inhein hum delocalized electrons kehte hain. [cheerful] Is tarah positive metal ions ka lattice ban jata hai jo delocalized electrons ke sea ya cloud mein surrounded hota hai, aur in dono ke beech strong electrostatic attraction hi metallic bond hai!	media/lectures/1_3_slide_1.mp3	2026-04-19 12:52:26.388275
28	1.3	2	The Sea of Delocalized Electrons	["Delocalized electrons do not belong to any particular atom", "Free to move throughout entire metallic structure", "Form a 'sea' or 'cloud' around positive metal ions", "These electrons maintain bonding in the metal"]	[interest] Ab yeh delocalized electrons ko detail mein samajhte hain! [soft] Yeh electrons kisi ek particular atom se belong nahi karte, bilkul jaise bazaar mein bijli ki wires sab ke liye hoti hain, kisi ek dukaan ki nahi. [enthusiasm] Yeh electrons poore metallic structure mein freely move kar sakte hain - left se right, up se down, har taraf! [cheerful] In free electrons ka jo sea ya cloud banta hai positive metal ions ke around, wohi toh metallic bonding ki asli strength hai. [short pause] Yeh mobile electrons hi metal ke saare special properties explain karte hain jo hum aage dekhenge.	media/lectures/1_3_slide_2.mp3	2026-04-19 12:52:26.388275
29	1.3	3	Electrical Conductivity of Metals	["Delocalized electrons can move freely through metal", "When voltage applied, electrons move in one direction", "This movement of electrons constitutes electric current", "Explains why metals are excellent electrical conductors"]	[enthusiasm] Bachon, ab dekhte hain ke metals mein electricity itni achhi tarah se kyun flow karti hai! [serious] Yaad rakho ke delocalized electrons freely move kar sakte hain throughout the metal. [interest] Jab hum voltage apply karte hain metal ke across, toh yeh free electrons ek hi direction mein move karne lagte hain - bilkul jaise mobile phone charging mein electrons battery ki taraf move karte hain. [cheerful] Aur yeh directed movement of electrons hi toh electric current hai! [soft] Is liye metals excellent electrical conductors hote hain kyunke inke paas freely moving electrons hote hain - copper aur aluminum wires isi liye use hote hain bijli ke connections mein.	media/lectures/1_3_slide_3.mp3	2026-04-19 12:52:26.388275
30	1.3	4	Thermal Conductivity of Metals	["Mobile electrons transfer kinetic energy rapidly", "When heated, electrons carry energy to cooler parts", "Heat spreads quickly throughout metal structure", "Makes metals excellent thermal conductors"]	[interest] Ab thermal conductivity ki baat karte hain! [soft] Jab metal ka ek part garam hota hai, toh mobile electrons us heat energy ko rapidly transfer karte hain doosre parts mein. [enthusiasm] Bilkul jaise chai banate waqt chamcha garam ho jata hai - iska matlab electrons kinetic energy ko quickly transfer kar rahe hote hain! [cheerful] Yeh free electrons heat ko itni jaldi ek jagah se doosri jagah le jaate hain ke poora metal structure uniformly garam ho jata hai. [serious] Is liye metals excellent thermal conductors hote hain aur cooking ke utensils mein use hote hain.	media/lectures/1_3_slide_4.mp3	2026-04-19 12:52:26.388275
31	1.3	5	Strength of Metallic Bond	["Depends on number of delocalized electrons per atom", "Depends on charge density of metal ions", "More electrons mean stronger metallic bonding", "Higher charge density increases bond strength"]	[serious] Ab ye samajhna zaroori hai ke metallic bond ki strength kis cheez par depend karti hai. [interest] Pehli baat - jitne zyada delocalized electrons per atom honge, utni hi zyada strong bonding hogi, bilkul jaise cricket team mein zyada players hain toh team zyada strong hoti hai. [soft] Doosri baat - metal ions ka charge density bhi matter karta hai. [enthusiasm] Agar ion ka charge zyada hai aur size chota hai, toh charge density zyada hoga aur attraction zyada strong hoga electrons ke saath. [cheerful] Yeh dono factors milkar decide karte hain ke metallic bond kitna strong hoga!	media/lectures/1_3_slide_5.mp3	2026-04-19 12:52:26.388275
32	1.3	6	Malleability: Metals Can Be Hammered	["Malleability means metals can be hammered into sheets", "Layers of metal ions can slide past each other", "Delocalized electrons rearrange to maintain bonding", "Metallic bond does not break during deformation"]	[cheerful] Ab hum metals ki mechanical properties dekhte hain! [enthusiasm] Malleability ka matlab hai ke metals ko hammer kar ke sheets bana sakte hain - jaise aluminum foil! [interest] Yeh possible hota hai kyunke metal ions ki layers ek doosre ke upar se slide kar sakti hain. [soft] Jab ek layer move karti hai, toh delocalized electrons apne aap rearrange ho jaate hain new positions mein, bilkul jaise baarish mein do friends umbrella share karte hain aur position change karne par bhi umbrella dono ko cover karta rehta hai. [serious] Important baat ye hai ke is process mein metallic bond break nahi hota - electrons simply rearrange ho kar bonding maintain karte rehte hain!	media/lectures/1_3_slide_6.mp3	2026-04-19 12:52:26.388275
33	1.3	7	Ductility: Metals Can Be Drawn	["Ductility means metals can be drawn into wires", "Layers slide without breaking metallic bond", "Delocalized electrons maintain bonding after movement", "Same principle as malleability but different shape"]	[interest] Ductility bhi malleability jaisi property hai lekin isme metal ko wires mein draw karte hain. [cheerful] Copper ki wires jo ghar mein bijli ke liye use hoti hain, woh ductility ki perfect example hain! [soft] Yahan bhi wahi mechanism kaam kar raha hai - metal ions ki layers ek doosre ke saath slide karti hain jab metal ko pull karte hain. [enthusiasm] Aur delocalized electrons itne smart hain ke woh naye arrangement mein bhi bonding maintain kar lete hain, bilkul jaise roti share karte waqt siblings apni positions change karte hain lekin roti sabko mil hi jati hai! [serious] Metallic bond break nahi hota is process mein - yahi metals ki specialty hai.	media/lectures/1_3_slide_7.mp3	2026-04-19 12:52:26.388275
34	1.3	8	Metals vs Ionic Compounds Structure	["Metals: layers slide easily, bond remains intact", "Ionic compounds: deformation brings like charges together", "Like charges repel causing fracture in ionic solids", "This explains why ionic compounds are brittle"]	[serious] Ab hum metallic aur ionic compounds ki comparison karte hain. [interest] Metals mein jab layers slide karti hain toh delocalized electrons rearrange ho kar bond intact rakhte hain - yeh hum ne dekha. [soft] Lekin ionic compounds mein situation bilkul alag hai! [enthusiasm] Jab ionic lattice ko deform karne ki koshish karte hain, toh like-charged ions ek doosre ke paas aa jaate hain - positive ke paas positive aur negative ke paas negative. [serious] Aur physics ki basic rule yaad rakho - like charges repel karte hain! [long pause] Is repulsion ki wajah se ionic compound crack ho jata hai aur fracture kar jata hai. Is liye ionic compounds brittle hote hain jabke metals malleable aur ductile hote hain - yeh metallic bonding ka kamal hai!	media/lectures/1_3_slide_8.mp3	2026-04-19 12:52:26.388275
35	1.4	1	What is a Polar Covalent Bond?	["Covalent bond with unequal sharing of electrons", "Occurs when atoms have different electronegativities", "Electronegativity difference between 0.4 to 1.7", "Creates partial positive and negative charges"]	[enthusiasm] Assalam-o-alaikum bachon! Aaj hum ek bohot important topic shuru kar rahe hain - polar covalent bonds. [interest] Dekho, pehle humne seekha tha ke covalent bond mein electrons share hote hain, lekin aaj hum dekhenge ke yeh sharing hamesha equal nahi hoti. [soft] Polar covalent bond wo bond hai jisme electrons unequally share hote hain - matlab ek atom electrons ko zyada attract karta hai aur doosra kam. [short pause] Bilkul aise socho jaise do bhai roti share kar rahe hain lekin ek bhai zyada strong hai toh wo roti apni taraf zyada kheench leta hai - roti dono ke darmiyan hai lekin equally divided nahi hai. [serious] Yeh unequal sharing tab hoti hai jab dono atoms ki electronegativity different hoti hai. [enthusiasm] Electronegativity wo ability hai jiske zariye atom bonding electrons ko apni taraf attract karta hai - jis atom ki electronegativity zyada, wo electrons ko zyada khenchega. [interest] Ab yahan ek specific range hai - agar do atoms ki electronegativity difference 0.4 se 1.7 ke darmiyan ho, toh polar covalent bond banta hai. [soft] Is range se kam ho toh pure covalent bond banega, aur is se zyada ho toh ionic bond ban sakta hai. [cheerful] Is unequal sharing ki wajah se ek interesting cheez hoti hai - partial charges ban jate hain! [serious] Jis atom ki electronegativity zyada hoti hai, uske paas electrons zyada time guzarte hain, toh us atom par partial negative charge aa jata hai jise hum delta minus (δ-) se show karte hain. [short pause] Aur doosre atom par, jis ki electronegativity kam hai, partial positive charge aa jata hai jise delta plus (δ+) se dikhate hain. [enthusiasm] Yeh partial charges poore charges nahi hain jaise ionic bond mein hote hain, balke chhote se charges hain jo bond ko polar bana dete hain. [serious] Exam mein agar poochha jaye ke polar covalent bond kya hai, toh clear likhna: unequal sharing of electrons between atoms with different electronegativities, creating partial charges.	media/lectures/1_4_slide_1.mp3	2026-04-19 14:03:38.853453
36	1.4	2	Electronegativity: The Key to Polarity	["Electronegativity measures atom's electron-attracting power", "Higher electronegativity means stronger electron attraction", "Different elements have different electronegativity values", "Pauling scale used to measure electronegativity"]	[interest] Bachon, ab hum detail mein samjhte hain ke electronegativity actually hai kya cheez. [soft] Electronegativity ek atom ki wo ability hai jis se wo bonding electrons ko apni taraf attract kar sakta hai - yeh ek measurement hai atom ki pulling power ki. [enthusiasm] Socho jaise bazaar mein do dukandaar ek hi customer ko apni taraf bulane ki koshish kar rahe hain - jis ki awaaz zyada loud aur convincing, customer us ki taraf zyada attract hoga! [short pause] Yahan electron wo customer hai aur atoms wo dukandaar hain. [serious] Jis atom ki electronegativity zyada hoti hai, wo electrons ko zyada strongly attract karega aur electrons us atom ke paas zyada time spend karenge. [interest] Periodic table mein different elements ki electronegativity values different hoti hain - yeh koi random nahi hai, is mein pattern hai. [soft] Generally, right side ke elements ki electronegativity zyada hoti hai, aur Fluorine sabse zyada electronegative element hai. [cheerful] Left side ke metals ki electronegativity kam hoti hai kyunke wo electrons dena chahte hain, attract nahi karna chahte. [enthusiasm] In values ko measure karne ke liye hum Pauling scale use karte hain jo ek scientist Linus Pauling ne banaya tha. [short pause] Is scale par Fluorine ki value 4.0 hai jo sabse zyada hai, aur doosre elements ki values is se kam hain. [serious] Jab hum do atoms ka polar covalent bond dekhte hain, toh hum unki electronegativity values ko subtract karte hain - agar difference 0.4 se 1.7 ke darmiyan hai toh polar covalent bond hai. [interest] Yeh difference hi decide karta hai ke kitna polar bond hoga - zyada difference matlab zyada polarity. [serious] Exam mein electronegativity ki definition yaad rakhna bohot zaroori hai - examiners ye definition poochte hain aur marks isme depend karte hain.	media/lectures/1_4_slide_2.mp3	2026-04-19 14:03:38.853453
37	1.4	3	Example: Hydrogen Chloride (HCl)	["Chlorine is more electronegative than hydrogen", "Bonding electrons spend more time near chlorine", "Chlorine gets δ- and hydrogen gets δ+ charge", "Creates a dipole moment in the molecule"]	[enthusiasm] Chalo ab ek proper example se samjhte hain - Hydrogen Chloride ya HCl molecule. [interest] Is molecule mein hydrogen aur chlorine atoms covalent bond bana rahe hain, lekin yeh bond polar hai. [soft] Kyun? Kyunke chlorine ki electronegativity bohot zyada hai - around 3.0 - jabke hydrogen ki sirf 2.1 hai. [serious] Toh jab ye dono bond banate hain, chlorine apni strong pulling power se bonding electrons ko apni taraf zyada kheenchta hai. [short pause] Electrons ka time distribution equal nahi rehta - wo zyada time chlorine atom ke paas spend karte hain. [cheerful] Bilkul aise jaise agar aap aur aapka chhota bhai cricket khel rahe ho aur ball share kar rahe ho - lekin aap zyada strong ho toh ball zyada time aapke paas rehti hai! [enthusiasm] Is wajah se chlorine atom par thoda sa negative charge aa jata hai jo hum delta minus (δ-) se represent karte hain. [soft] Aur hydrogen atom par thoda sa positive charge aa jata hai kyunke uske electrons us se door zyada time rehte hain - ise delta plus (δ+) se dikhate hain. [interest] Is charge separation ko hum dipole moment kehte hain - yeh ek measurement hai ke kitna separation hai positive aur negative charges mein. [serious] Dipole moment ko hum arrow se show karte hain jo positive end se negative end ki taraf point karta hai. [short pause] HCl mein arrow hydrogen se chlorine ki taraf jaega. [enthusiasm] Yeh dipole moment hi HCl ko polar molecule banata hai aur isi wajah se HCl ka behavior different hota hai non-polar molecules se. [serious] Exam mein agar HCl ka example aaye toh zaroor mention karna ke Cl zyada electronegative hai, electrons uske paas zyada time spend karte hain, aur δ- chlorine par aur δ+ hydrogen par hota hai - complete answer yahi hai.	media/lectures/1_4_slide_3.mp3	2026-04-19 14:03:38.853453
38	1.4	4	Dipole Moments and Molecular Shape	["Dipole moment shows separation of charges", "Represented by arrow from positive to negative", "Molecular geometry determines if molecule is polar", "Bond dipoles may cancel out in symmetrical molecules"]	[interest] Bachon, ab ek aur important concept samjhte hain - dipole moment aur molecular shape ka relation. [soft] Dipole moment basically ek measurement hai jo batati hai ke molecule mein positive aur negative charges kitne separate hain. [enthusiasm] Jitna zyada separation, utna zyada dipole moment, aur utna zyada polar molecule hoga! [short pause] Hum dipole moment ko ek arrow se dikhate hain jo hamesha positive end se start hoke negative end par point karta hai. [serious] Yeh arrow bilkul us direction ko show karta hai jis mein negative charge hai. [interest] Lekin yahan ek twist hai - sirf polar bonds hona kaafi nahi hai molecule ko polar banane ke liye! [cheerful] Molecular geometry bhi bohot important role play karti hai. [soft] Socho jaise bijli ke do taar ek bulb ko khench rahe hain opposite directions mein - agar dono ki force equal ho toh bulb hilega nahi, cancel ho jayega! [enthusiasm] Waise hi agar molecule symmetrical hai aur polar bonds opposite directions mein hain, toh sab dipole moments cancel ho sakte hain. [serious] Jaise Carbon dioxide CO₂ mein do polar C=O bonds hain lekin molecule linear hai - dono dipoles opposite hain toh cancel ho jate hain aur CO₂ non-polar molecule ban jata hai. [short pause] Lekin water H₂O mein bhi do polar O-H bonds hain, lekin molecule bent shape mein hai, toh dipoles cancel nahi hote aur water ek bohot polar molecule hai. [interest] Is liye hamesha molecular geometry ko consider karna zaroori hai - yeh decide karta hai ke overall molecule polar hai ya nahi. [serious] Exam mein agar molecular polarity ka question ho toh sirf bonds ki polarity nahi, shape bhi discuss karni hogi - examiners complete reasoning chahte hain. [soft] Symmetrical molecules mein dipoles cancel hone ka concept zaroor mention karna agar applicable ho.	media/lectures/1_4_slide_4.mp3	2026-04-19 14:03:38.853453
39	1.4	5	Water: A Perfect Polar Molecule	["Water has two polar O-H bonds", "Oxygen is more electronegative than hydrogen", "Bent molecular shape prevents dipole cancellation", "Results in strong net dipole moment"]	[enthusiasm] Bachon, ab hum sabse famous polar molecule ke baare mein baat karte hain - paani ya water! [cheerful] Water jo hum roz peete hain, wo chemistry mein ek perfect example hai polar molecule ka. [interest] Water ka formula H₂O hai - is mein ek oxygen atom hai aur do hydrogen atoms hain. [soft] Oxygen ki electronegativity bohot zyada hai, around 3.5, jabke hydrogen ki sirf 2.1 hai. [serious] Toh jab oxygen hydrogen ke saath bond banata hai, wo bonding electrons ko strongly apni taraf attract karta hai. [short pause] Is wajah se dono O-H bonds polar ban jate hain - oxygen par partial negative charge (δ-) aur har hydrogen par partial positive charge (δ+) aa jata hai. [interest] Lekin yahan important point yeh hai ke water molecule ki shape bent hai, seedhi line mein nahi hai. [enthusiasm] Socho jaise koi parinda apne pankh failaye huye ho - oxygen center mein hai aur do hydrogen atoms angle par hain, approximately 104.5 degrees ka angle. [soft] Agar water linear hota jaise CO₂ hai, toh dono dipoles opposite hote aur cancel ho jate. [cheerful] Lekin bent shape ki wajah se dono dipoles ek hi general direction mein point karte hain aur add up ho jate hain! [serious] Is se water mein ek bohot strong net dipole moment banta hai jo oxygen side ko negative aur hydrogen side ko positive banata hai. [enthusiasm] Yeh strong polarity hi water ko itna special banati hai - isi wajah se paani mein namak dissolve hota hai, isi wajah se life possible hai! [short pause] Water molecules apas mein hydrogen bonding kar sakte hain jo bohot strong intermolecular force hai. [serious] Exam mein water ka example dete waqt teen cheezein zaroor mention karni hain: O-H bonds polar hain, bent shape hai, aur strong net dipole moment hai - yeh complete answer hai jo examiners expect karte hain.	media/lectures/1_4_slide_5.mp3	2026-04-19 14:03:38.853453
40	1.4	6	Effects on Physical Properties	["Polar molecules have higher boiling points", "Partial charges allow dipole-dipole interactions", "Stronger intermolecular forces than non-polar molecules", "Polar molecules dissolve in polar solvents"]	[interest] Ab dekhte hain ke polar covalent bonds molecule ki properties ko kaise affect karte hain. [enthusiasm] Yeh bohot practical cheez hai jo exams mein zaroor aati hai! [soft] Pehli important baat - polar molecules ka boiling point generally zyada hota hai compared to similar size ke non-polar molecules. [serious] Kyun? Kyunke partial charges ki wajah se molecules ke darmiyan stronger forces hoti hain. [interest] In forces ko hum dipole-dipole interactions kehte hain - jab ek molecule ka positive end doosre molecule ke negative end ko attract karta hai. [cheerful] Bilkul waise jaise magnets attract karte hain ek doosre ko! [short pause] Yeh attraction molecules ko hold karta hai aur unhe separate hona mushkil ho jata hai. [soft] Is liye zyada energy chahiye hoti hai unhe gas mein convert karne ke liye, aur boiling point barh jata hai. [enthusiasm] For example, water ka boiling point 100°C hai jo bohot zyada hai compared to similar molecular weight ke non-polar molecules. [serious] Non-polar molecules mein sirf weak Van der Waals forces hoti hain jo easily break ho jati hain, toh unka boiling point kam hota hai. [interest] Ab doosri important property - solubility ya dissolving ability. [cheerful] Hum chemistry mein kehte hain 'like dissolves like' - yeh golden rule hai! [soft] Matlab polar molecules polar solvents mein dissolve hote hain, aur non-polar molecules non-polar solvents mein. [enthusiasm] Water ek polar solvent hai toh yeh polar substances jaise namak (salt) ko ache se dissolve kar leta hai. [short pause] Jab namak paani mein dalte ho toh water molecules apne partial charges se ions ko attract karte hain aur dissolve kar dete hain. [serious] Lekin oil jo non-polar hai, wo paani mein dissolve nahi hota - yeh hum roz dekhte hain jab chai mein oil ki boondein upar tairti rehti hain! [interest] Yeh sab properties molecular polarity ki wajah se hoti hain. [serious] Exam mein agar properties ka question aaye toh higher boiling point aur solubility dono discuss karni hai, aur reason bhi dena hai ke dipole-dipole forces ki wajah se aisa hota hai.	media/lectures/1_4_slide_6.mp3	2026-04-19 14:03:38.853453
41	1.4	7	Common Examples of Polar Molecules	["Water (H₂O) - bent shape, highly polar", "Ammonia (NH₃) - pyramidal shape, polar", "Hydrogen fluoride (HF) - very polar bond", "All have electronegative atoms bonded to hydrogen"]	[enthusiasm] Chalo bachon, ab kuch important examples dekhte hain polar molecules ki jo exams mein frequently aate hain! [cheerful] Pehla toh hum already detail mein dekh chuke hain - water ya H₂O. [soft] Water bent shape mein hai aur oxygen ki high electronegativity ki wajah se bohot polar molecule hai. [interest] Doosra important example hai ammonia ya NH₃. [serious] Ammonia mein nitrogen atom center mein hai aur teen hydrogen atoms uske saath bonded hain. [short pause] Nitrogen ki electronegativity 3.0 hai jo hydrogen (2.1) se kaafi zyada hai, toh har N-H bond polar hai. [enthusiasm] Ammonia ki shape pyramidal hai - bilkul jaise koi pyramid ho - aur is asymmetrical shape ki wajah se dipoles cancel nahi hote. [soft] Is liye ammonia bhi ek polar molecule hai jo paani mein ache se dissolve hota hai. [interest] Teesra example hai hydrogen fluoride ya HF - yeh bohot hi polar molecule hai! [serious] Fluorine sabse zyada electronegative element hai with electronegativity 4.0, aur hydrogen ki sirf 2.1 hai. [enthusiasm] Toh in dono ke darmiyan electronegativity difference bohot zyada hai - around 1.9 - jo almost ionic bond ki range mein aa jata hai! [cheerful] Lekin kyunke yeh still covalent bond hai, toh hum ise highly polar covalent bond kehte hain. [short pause] HF mein fluorine par bohot strong partial negative charge hota hai aur hydrogen par strong partial positive. [interest] Ab ek pattern dekho - in teeno molecules mein kya common hai? [soft] Sab mein hydrogen hai jo kam electronegative hai, aur sab mein ek highly electronegative atom hai jaise oxygen, nitrogen, ya fluorine. [serious] Yeh combination hamesha highly polar bonds banata hai aur often hydrogen bonding bhi possible hoti hai. [enthusiasm] Yeh teen examples - H₂O, NH₃, aur HF - exams mein sabse zyada common hain polar molecules ke. [serious] In teeno ko yaad rakhna chahiye with their shapes aur kyun polar hain - examiners aksar specific examples maangte hain answers mein.	media/lectures/1_4_slide_7.mp3	2026-04-19 14:03:38.853453
42	1.5	1	What is Hydrogen Bonding?	["Special type of intermolecular force, not a true chemical bond", "Occurs between hydrogen and highly electronegative atoms (N, O, F)", "Hydrogen develops partial positive charge, attracts lone pairs", "Stronger than other intermolecular forces but weaker than covalent bonds"]	[enthusiasm] Assalam-o-Alaikum bacho! Aaj hum ek bohot interesting topic shuru kar rahe hain — hydrogen bonding. [interest] Pehli baat jo aapko samajhni hai woh yeh hai ke hydrogen bond ka naam toh bond hai, lekin yeh koi asli chemical bond nahi hai jaise covalent ya ionic bond hota hai. [soft] Yeh actually ek intermolecular force hai, matlab molecules ke beech mein jo attraction hota hai woh hai. [short pause] Bilkul waise jaise aap apne dost ke saath khade ho toh aapke beech mein friendship ka rishta hai, lekin woh family ka rishta nahi — bond toh hai magar different type ka. [serious] Ab yeh hydrogen bonding kab hoti hai? [interest] Jab hydrogen atom kisi bohot zyada electronegative atom ke saath covalent bond banata hai — jaise nitrogen, oxygen, ya fluorine — tab yeh special force banti hai. [enthusiasm] Dekho kya hota hai: hydrogen chhota sa atom hai aur uska electron toh us electronegative atom ki taraf khainch jata hai. [soft] Is wajah se hydrogen ke paas partial positive charge aa jata hai, bilkul waise jaise agar aap apni blanket apne bhai ko de do toh aap thande ho jate ho — hydrogen ne apna electron share kiya toh woh partially positive ban gaya. [interest] Ab yeh partially positive hydrogen kisi doosri molecule mein jo electronegative atom hai uske lone pair of electrons ki taraf attract hota hai. [cheerful] Yeh attraction hi hydrogen bonding kahlati hai! [serious] Aur ek bohot important exam point: hydrogen bond other intermolecular forces jaise van der Waals se zyada strong hota hai, lekin covalent bond se kaafi weak hota hai — sirf 5 percent strength hai covalent bond ki. [short pause] Examiners aksar poochte hain ke hydrogen bond aur covalent bond mein kya difference hai, toh aapko yeh clearly likhna hai ke hydrogen bond is an intermolecular force, not an intramolecular bond.	media/lectures/1_5_slide_1.mp3	2026-04-19 15:06:31.091233
43	1.5	2	Conditions for Hydrogen Bonding	["Hydrogen must be bonded to N, O, or F atom", "These atoms are highly electronegative and small", "Hydrogen becomes partially positive (δ+)", "Nearby molecule must have electronegative atom with lone pairs"]	[serious] Ab hum dekhte hain ke hydrogen bonding ke liye specific conditions kya hain. [interest] Sabse pehli shart yeh hai ke hydrogen ko directly nitrogen, oxygen, ya fluorine ke saath bonded hona chahiye — sirf yeh teen atoms ke saath. [soft] Aap soch rahe honge ke kyun sirf yeh teen? [enthusiasm] Kyunke yeh teen sabse zyada electronegative elements hain aur size mein bhi bohot chhote hain. [short pause] Jab hydrogen in ke saath bond banata hai toh yeh itna zyada electrons ko apni taraf kheenchte hain ke hydrogen ka electron almost poora in ki taraf shift ho jata hai. [interest] Bilkul jaise agar do bachche roti share kar rahe hain aur ek baccha bohot strong hai toh woh poori roti apni taraf kheench leta hai — oxygen ya nitrogen itne strong hain ke electrons ko apni taraf kheench lete hain. [cheerful] Is wajah se hydrogen pe partial positive charge aa jata hai, jise hum δ+ (delta plus) se show karte hain. [soft] Hydrogen ab ek chhote se magnet ki tarah hai jo positive charge rakhe hue hai. [serious] Lekin sirf itna kaafi nahi — hydrogen bonding ke liye ek aur zaroori cheez chahiye. [interest] Kisi nearby molecule mein ek electronegative atom hona chahiye jis ke paas lone pair of electrons ho. [enthusiasm] Yeh lone pairs negative charge rakhte hain toh woh us partially positive hydrogen ko attract karte hain! [short pause] Jaise bazaar mein agar aap paise pakde khade ho toh dukandaar aapko apni taraf bulata hai — waise hi lone pairs us positive hydrogen ko attract karte hain. [serious] Exam mein agar question ho ke 'Why does hydrogen bonding occur between water molecules?', toh aapko likhna hai: oxygen is highly electronegative, making hydrogen partially positive, which then attracts lone pairs on oxygen of another water molecule.	media/lectures/1_5_slide_2.mp3	2026-04-19 15:06:31.091233
44	1.5	3	Hydrogen Bonding in Water	["Water has unusually high boiling point (100°C) for its small size", "Each water molecule can form up to four hydrogen bonds", "Two bonds through H atoms, two through O lone pairs", "Extensive hydrogen bonding network gives water unique properties"]	[enthusiasm] Bacho, ab hum paani ki baat karte hain jo sabse best example hai hydrogen bonding ka! [interest] Pehle yeh samjho ke paani ka boiling point 100°C hai, jo bohot high hai itni chhoti molecule ke liye. [soft] Agar tum doosri chhoti molecules dekho jinka size paani jitna hai, unka boiling point minus temperatures mein hota hai. [short pause] Lekin paani ka 100°C kyun? [enthusiasm] Sab kuch hydrogen bonding ki wajah se hai! [cheerful] Paani ki molecule mein ek oxygen aur do hydrogen atoms hote hain. [interest] Har paani ki molecule chaar hydrogen bonds bana sakti hai — yeh bohot important point hai exam ke liye. [serious] Do hydrogen bonds toh hydrogen atoms ke through banti hain, kyunke yeh hydrogen partially positive hain toh doosri molecules ke oxygen ko attract karte hain. [soft] Aur do hydrogen bonds oxygen ke lone pairs ke through banti hain, kyunke oxygen ke paas do lone pairs hote hain jo doosri molecules ke hydrogen atoms ko attract karte hain. [enthusiasm] Bilkul jaise cricket team mein har player apne saath walon se connect hota hai — koi batting mein help karta hai, koi bowling mein. [interest] Waise hi har water molecule chaar taraf se doosri molecules ke saath hydrogen bonding kar rahi hoti hai! [short pause] Yeh itna strong network ban jata hai ke molecules ko alag karna bohot mushkil ho jata hai. [serious] Is liye jab paani ko boil karna ho toh bohot zyada energy chahiye hoti hai in hydrogen bonds ko todne ke liye. [cheerful] Is liye boiling point itna high hai! [soft] Exam mein agar poochha jaye 'Explain why water has a high boiling point', toh aapko likhna hai: water molecules form extensive hydrogen bonding network where each molecule can form four hydrogen bonds, requiring large amount of energy to break these bonds during boiling.	media/lectures/1_5_slide_3.mp3	2026-04-19 15:06:31.091233
45	1.5	4	Ice Structure and Density	["Ice is less dense than liquid water — unique property", "Hydrogen bonds arrange molecules in hexagonal lattice structure", "More space between molecules in ice than in liquid water", "Ice floats on water, protecting aquatic life in winter"]	[interest] Ab ek aur bohot amazing cheez dekhte hain paani ke baare mein. [enthusiasm] Jab paani freeze hota hai aur baraf banti hai, toh baraf paani pe float karti hai! [soft] Yeh bohot unusual hai kyunke normally solids apne liquids se zyada dense hote hain. [short pause] Lekin paani ke saath ulta hai — ice kam dense hai liquid water se. [serious] Is ka poora credit hydrogen bonding ko jata hai. [interest] Jab paani liquid form mein hota hai toh molecules freely move kar rahi hoti hain, close packed hoti hain. [enthusiasm] Lekin jab temperature bohot kam ho jata hai aur freezing shuru hoti hai, toh hydrogen bonds molecules ko ek special structure mein arrange kar deti hain. [cheerful] Yeh structure hexagonal lattice kahlati hai — chhe sides wali structure, bilkul honeycomb jaisi! [soft] Is hexagonal arrangement mein molecules ke beech mein bohot zyada space ho jati hai. [interest] Bilkul jaise agar aap apne doston ke saath circle mein khade ho formal photo ke liye, toh aapke beech mein space hoti hai. [short pause] Lekin agar normally classroom mein khade ho toh sab close packed hote hain. [serious] Waise hi ice mein molecules zyada spaced out hain compared to liquid water. [enthusiasm] Is wajah se ice ka density kam ho jata hai aur woh float karti hai! [interest] Yeh nature ke liye bohot important hai kyunke jab rivers aur lakes freeze hoti hain winters mein, toh sirf upar se jamti hain. [soft] Neeche liquid water rehta hai jismein machliyan aur doosre aquatic animals zinda reh sakte hain. [cheerful] Agar ice zyada dense hoti toh neeche baith jati aur saara paani jam jata — sab aquatic life khatam ho jati! [serious] Exam mein agar poochha jaye 'Why does ice float on water?', toh clear likho: hydrogen bonds arrange water molecules in a hexagonal lattice structure in ice, creating more space between molecules than in liquid water, making ice less dense.	media/lectures/1_5_slide_4.mp3	2026-04-19 15:06:31.091233
46	1.5	5	Hydrogen Bonding in DNA	["DNA double helix held together by hydrogen bonds between base pairs", "Adenine bonds with Thymine, Guanine bonds with Cytosine", "Bonds strong enough to maintain structure during normal conditions", "Weak enough to allow separation during replication and transcription"]	[enthusiasm] Bacho, ab hum dekhte hain ke hydrogen bonding biology mein kitni important hai! [interest] Aapne DNA ka naam suna hoga — yeh woh genetic material hai jo har living thing mein hota hai. [serious] DNA ki structure double helix hai, matlab do strands hain jo ek doosre ke around twist hoke spiral banti hain. [short pause] Lekin yeh do strands ek saath kaise hold hote hain? [cheerful] Jawab hai hydrogen bonding! [soft] DNA mein nitrogenous bases hote hain — Adenine, Thymine, Guanine, aur Cytosine. [interest] Yeh bases complementary pairs banate hain: Adenine hamesha Thymine ke saath pair karta hai, aur Guanine hamesha Cytosine ke saath. [enthusiasm] In pairs ke beech mein hydrogen bonds banti hain jo dono strands ko ek saath hold karti hain! [short pause] Bilkul jaise zipper ke do sides hain jo teeth se connect hoti hain, waise hi DNA ke do strands hydrogen bonds se connected hain. [serious] Ab yeh bohot cleverly designed hai. [interest] Hydrogen bonds itni strong hain ke normal conditions mein DNA ki structure stable rehti hai — toot nahi jati. [soft] Lekin yeh itni weak bhi hain ke jab zaroorat ho, jaise DNA replication ke time ya transcription ke time, toh easily alag ho sakti hain. [enthusiasm] Matlab agar covalent bonds hoti toh DNA kholna bohot mushkil hota, lekin hydrogen bonds perfect balance deti hain! [cheerful] Bilkul jaise aap apni notebook mein pages rakhte ho — woh girte nahi lekin jab zaroorat ho toh easily nikaal sakte ho. [serious] Cell division ke time DNA ki strands alag hoti hain taake nayi copies ban sakein. [soft] Hydrogen bonds ki yeh balanced strength is process ko possible banati hai. [interest] Exam mein agar DNA aur hydrogen bonding ka question aaye, toh zaror likho: hydrogen bonds between complementary base pairs hold DNA strands together, providing stability while allowing separation during replication.	\N	2026-04-19 15:06:31.091233
47	1.5	6	Hydrogen Bonding in Proteins	["Proteins have complex three-dimensional structures", "Hydrogen bonds stabilize secondary structures like alpha helices and beta sheets", "Bonds form between C=O and N-H groups in protein backbone", "Essential for protein function in biological systems"]	[interest] Ab hum dekhte hain proteins mein hydrogen bonding ka role. [soft] Proteins bohot important molecules hain hamare body mein — enzymes, antibodies, hormones sab proteins hain. [serious] Proteins ki functionality unki shape pe depend karti hai, aur yeh shape maintain karne mein hydrogen bonding bohot badi role play karti hai. [enthusiasm] Proteins long chains hoti hain amino acids ki, aur yeh chains different shapes mein fold ho jati hain. [interest] Do common secondary structures hain: alpha helix aur beta sheet. [short pause] Alpha helix ek spiral structure hai jaise spring ya telephone ki purani wire, aur beta sheet ek zigzag folded structure hai. [cheerful] Yeh structures ko stable rakhne ka kaam hydrogen bonds karte hain! [soft] Protein ki backbone mein C=O groups hote hain (carbonyl groups) aur N-H groups hote hain (amine groups). [enthusiasm] In dono ke beech mein hydrogen bonding hoti hai jo structure ko lock kar deti hai! [interest] Bilkul jaise jab aap koi badi building banate ho toh pillars aur beams ko bolts se fasten karte ho taake structure strong rahe. [short pause] Waise hi hydrogen bonds protein ki structure ko fasten kar deti hain. [serious] Agar yeh hydrogen bonds na ho toh protein fold nahi ho paayegi properly, aur function karna band kar degi. [soft] Bohot sari diseases mein hota yeh hai ke proteins misfold ho jati hain kyunke hydrogen bonding disturb ho jati hai. [interest] Jaise agar chai banate waqt doodh phat jaye toh taste kharab ho jata hai, waise hi agar protein ki folding galat ho jaye toh kaam nahi karti. [cheerful] Enzymes ko apna shape chahiye hota hai substrates ke saath fit hone ke liye — yeh sab hydrogen bonding maintain karti hai! [serious] Exam perspective se, agar poochha jaye 'What is the role of hydrogen bonding in proteins?', toh likhna hai: hydrogen bonds stabilize secondary structures such as alpha helices and beta sheets by forming between carbonyl and amine groups in the protein backbone, which is essential for proper protein function.	\N	2026-04-19 15:06:31.091233
48	1.5	7	Comparing Bond Strengths	["Hydrogen bonds are about 5% the strength of covalent bonds", "Much stronger than other intermolecular forces (van der Waals)", "Strength: Covalent > Ionic > Hydrogen bonding > Dipole-dipole > London forces", "Sufficient strength for biological processes but allow flexibility"]	[serious] Bacho, ab bohot important topic hai — bonds ki strength ka comparison. [interest] Yeh samajhna zaroori hai ke different bonds kitne strong ya weak hote hain. [short pause] Sabse strong bonds hote hain covalent bonds aur ionic bonds — yeh actual chemical bonds hain jo atoms ko ek saath hold karte hain molecules ya compounds mein. [soft] Hydrogen bond is se bohot kamzor hai — sirf 5 percent strength hai covalent bond ki. [enthusiasm] Lekin phir bhi yeh bohot important hai! [cheerful] Agar hum comparison karein toh yeh sequence yaad rakho: Covalent sabse strong, phir Ionic, phir Hydrogen bonding, phir Dipole-dipole interactions, aur sabse weak London dispersion forces. [interest] Bilkul jaise mobile ka signal hota hai — 5G sabse fast, phir 4G, phir 3G, phir 2G. [short pause] Har ek ka apna kaam hai lekin strength different hai. [serious] Hydrogen bonds other intermolecular forces se kaafi zyada strong hain jaise van der Waals forces ya London forces. [soft] Is liye hi water ka boiling point itna high hai compared to other small molecules. [enthusiasm] Biology mein toh yeh perfect balance hai! [interest] Dekho, agar DNA aur proteins mein covalent bonds hote structures hold karne ke liye, toh woh kabhi change nahi kar paate — DNA replicate nahi kar paata, proteins fold aur unfold nahi kar paate. [cheerful] Lekin agar bohot weak forces hote toh structures stable nahi rehte — DNA toot jata, proteins bikhar jaate! [short pause] Hydrogen bonding exactly perfect hai — stable bhi, flexible bhi. [serious] Yeh bilkul waise hai jaise bijli ka connection — na toh itna loose hona chahiye ke plug nikal jaaye, na itna tight ke nikal hi na sake. [soft] Exam mein agar comparison poochha jaye, toh clearly order likhna aur approximate strength bhi mention karna ke hydrogen bond is 5% of covalent bond strength.	\N	2026-04-19 15:06:31.091233
49	4.5	1	What is Electrolysis?	["Electrolysis decomposes ionic compounds using electricity", "Electrolyte must be molten or dissolved in water", "Solid ionic compounds cannot conduct electricity", "Mobile ions carry the electric current through electrolyte"]	[enthusiasm] Assalamu alaikum bacho! Aaj hum ek bahut hi interesting aur important topic shuru kar rahe hain - Electrolysis. [interest] Dekho, electrolysis ek aisi process hai jismein hum electricity use karke ionic compounds ko break kar dete hain, decompose kar dete hain. [short pause] Bilkul waise jaise agar aap mobile ka charger tod dein toh andar se wires aur parts nikal aate hain, waise hi electricity use karke hum compounds ko unke parts mein tod sakte hain. [soft] Ab samajhne wali baat yeh hai ke jo compound hum decompose kar rahe hain, use electrolyte kehte hain. [serious] Lekin yeh electrolyte solid form mein nahi hona chahiye - yeh zaroor molten hona chahiye ya phir pani mein dissolved hona chahiye, warna process kaam nahi karega. [long pause] Ab socho ke kyun? [interest] Dekho jab ionic compound solid state mein hota hai, toh iske ions bilkul fixed positions mein stuck hote hain, bilkul waise jaise cricket stadium mein sab log apni apni seats par baithe hote hain aur hil nahi sakte. [enthusiasm] Lekin jab hum is compound ko melt kar dein ya pani mein dissolve kar dein, toh yeh ions free ho jate hain aur move kar sakte hain! [cheerful] Yeh mobile ions hi current ko carry karte hain ek electrode se dusre electrode tak. [serious] Exam mein agar poochha jaye ke electrolysis kya hai, toh clearly likhna hai: decomposition of an ionic compound using electricity when molten or in aqueous solution. [soft] Yeh definition bilkul yaad rakho.	media/lectures/4_5_slide_1.mp3	2026-04-19 16:46:09.057836
54	4.5	6	Electrolysis of Brine (Chlor-Alkali Process)	["Brine is concentrated sodium chloride solution (NaCl)", "Hydrogen gas produced at cathode from water", "Chlorine gas produced at anode from chloride ions", "Sodium hydroxide solution remains in electrolyte"]	[enthusiasm] Bacho, yeh bahut important industrial process hai jo O-Level mein zyada poocha jata hai! [interest] Brine matlab concentrated sodium chloride solution - yani namak ka concentrated solution pani mein. [soft] Jab hum iska electrolysis karte hain toh teen cheezein milti hain jo teeno industrially bahut valuable hain. [short pause] Cathode par kya hota hai? [serious] Wahan hydrogen ions jo pani se aate hain, woh reduce hote hain aur hydrogen gas banate hain. [interest] Sodium ions (Na⁺) bhi cathode ki taraf jaate hain lekin discharge nahi hote kyunke sodium bahut reactive hai, pani ke hydrogen ions ki discharge zyada asaan hai. [long pause] Anode par chloride ions (Cl⁻) jaate hain aur oxidize hote hain. [enthusiasm] Yeh chlorine gas ban jati hai jo greenish-yellow colour ki hoti hai aur bahut pungent smell hoti hai. [cheerful] Ab socho sodium ions aur hydroxide ions (jo pani se bante hain) solution mein reh jaate hain, toh humein sodium hydroxide solution mil jata hai! [soft] Bilkul jaise agar cricket match mein kuch players field par khel rahe hon aur kuch pavilion mein baithe hon, waise hi kuch ions discharge hote hain aur kuch solution mein hi rehte hain. [interest] Is process ko chlor-alkali process kehte hain kyunke chlorine aur alkali (sodium hydroxide) dono milte hain. [serious] Yeh process industrially itni important kyun hai? [enthusiasm] Kyunke hydrogen gas fuel ke liye use hoti hai, chlorine gas plastics aur disinfectants banane mein use hoti hai, aur sodium hydroxide soap aur paper industry mein use hota hai. [short pause] Toh ek hi process se teen valuable products mil jaate hain! [serious] Exam mein agar chlor-alkali process poocha jaye toh clearly mention karo: H₂ at cathode, Cl₂ at anode, NaOH remains in solution. [soft] Yeh point itna important hai ke almost har year O-Level mein kisi na kisi form mein aata hai.	media/lectures/4_5_slide_6.mp3	2026-04-19 16:46:09.057836
50	4.5	2	Electrodes: Cathode and Anode	["Cathode is connected to negative terminal of power supply", "Anode is connected to positive terminal of power supply", "Cations (positive ions) migrate toward cathode", "Anions (negative ions) migrate toward anode"]	[interest] Achha bacho, ab hum electrodes ke baare mein baat karte hain. [soft] Electrolysis mein do electrodes hote hain aur yeh bahut important hain samajhna. [enthusiasm] Pehla electrode hai cathode - yeh negative terminal se connected hota hai battery ya power supply ka. [short pause] Doosra electrode hai anode - yeh positive terminal se connected hota hai. [serious] Ab yeh names thode confusing lag sakte hain initially, lekin main aapko ek trick batata hoon: Cathode mein 'c' hai aur 'c' negative charge ki taraf point karta hai jaise chand ghatne ka symbol, toh cathode negative hai. [laughs] Thodi silly trick hai lekin kaam karti hai! [long pause] Ab ions ka migration samajhte hain. [interest] Dekho, jab hum electrolyte mein electrodes daal dete hain aur current flow karte hain, toh ions move karna shuru kar dete hain. [enthusiasm] Positive ions jo cations kehlate hain, woh cathode ki taraf jaate hain kyunke opposite charges attract karte hain - bilkul jaise do magnets ek dusre ko kheenchte hain. [soft] Aur negative ions jo anions kehlate hain, woh anode ki taraf migrate karte hain. [cheerful] Socho jaise Lahore se Karachi jaane wale log ek direction mein ja rahe hain aur Karachi se Lahore wale dusri direction mein - aise hi ions bhi opposite directions mein travel karte hain. [serious] Examiners yeh zaroor dekhte hain ke aapko pata hai ke cathode negative hai, anode positive hai, aur ions opposite electrode ki taraf jaate hain. [interest] Yeh concept bilkul clear hona chahiye wrna puri electrolysis samajh nahi aayegi.	media/lectures/4_5_slide_2.mp3	2026-04-19 16:46:09.057836
51	4.5	3	Reactions at Electrodes	["At cathode: Cations gain electrons (reduction reaction)", "At anode: Anions lose electrons (oxidation reaction)", "Remember: Reduction at cathode, Oxidation at anode", "Products formed are neutral atoms or molecules"]	[enthusiasm] Achha bacho, ab sabse interesting part aata hai - electrodes par kya reactions hote hain! [interest] Jab ions electrodes tak pohanchte hain toh wahan chemical reactions hote hain. [soft] Cathode par jo cations aate hain, woh electrons gain kar lete hain. [short pause] Dekho cathode negative hai toh wahan extra electrons available hain, aur yeh electrons cations ko mil jate hain. [serious] Jab koi ion electrons gain karta hai toh ise reduction reaction kehte hain - yeh bahut important term hai O-Level mein. [long pause] Bilkul opposite cheez anode par hoti hai. [interest] Anode par anions aate hain jo already negative hain matlab extra electrons ke saath hain. [enthusiasm] Yahan yeh apne extra electrons lose kar dete hain, chhod dete hain - aur jab electrons lose hon toh ise oxidation reaction kehte hain. [cheerful] Main aapko ek trick batata hoon yaad rakhne ke liye: OIL RIG - Oxidation Is Loss, Reduction Is Gain. [laughs] Yeh chemistry ki famous saying hai! [soft] Jab yeh reactions complete ho jate hain toh products neutral ban jate hain - na positive na negative, bilkul normal atoms ya molecules. [interest] Samajhne ke liye ek example deta hoon: jaise agar aap apni ammi se 50 rupay maango chai peene ke liye aur woh de dein, toh aapko gain hua - yeh reduction jaise hai. [short pause] Lekin agar aapke bhai ne aapse woh 50 rupay maang liye aur aapko dene pare, toh aapko loss hua - yeh oxidation jaise hai. [serious] Exam mein clearly likhna hai: at cathode reduction occurs, at anode oxidation occurs, aur OIL RIG use kar sakte ho definition yaad rakhne ke liye.	media/lectures/4_5_slide_3.mp3	2026-04-19 16:46:09.057836
52	4.5	4	Electrolysis of Molten Lead Bromide	["Lead bromide must be molten for electrolysis", "At cathode: Lead metal (Pb) is deposited", "At anode: Bromine gas (Br₂) is released", "Half equations show electron transfer clearly"]	[interest] Achha bacho, ab hum ek practical example dekhte hain taake sab kuch clear ho jaye. [enthusiasm] Lead bromide ka formula hai PbBr₂ - is mein lead ions (Pb²⁺) aur bromide ions (Br⁻) hote hain. [soft] Pehle hume ise molten karna padta hai matlab itna garam karna hai ke yeh liquid ban jaye, kyunke solid state mein ions move nahi kar sakte jaise humne pehle padha. [short pause] Jab yeh molten ho jata hai aur hum electrodes daal ke current pass karte hain, toh ions move karna shuru karte hain. [interest] Lead ions jo Pb²⁺ hain, positive hain toh cathode ki taraf jaate hain jo negative hai. [serious] Wahan cathode par yeh do electrons gain karte hain aur neutral lead metal ban jate hain - yeh silvery grey metal cathode par jamaa ho jata hai, deposit ho jata hai. [long pause] Dusri taraf anode par kya ho raha hai? [enthusiasm] Bromide ions (Br⁻) jo negative hain, anode ki taraf migrate kar rahe hain. [cheerful] Wahan yeh apna extra electron lose kar dete hain aur bromine gas ban jati hai jo brown colour ki hoti hai aur anode ke paas se release hoti hai. [soft] Bilkul waise jaise jab aap chai banate ho toh pani neeche bartan mein rehta hai lekin bhap upar nikalta hai - waise hi solid lead neeche jamaa hota hai aur gas upar nikalta hai. [interest] Half equations likhna O-Level mein bahut important hai. [serious] Cathode par: Pb²⁺ + 2e⁻ → Pb (yeh reduction hai). Anode par: 2Br⁻ → Br₂ + 2e⁻ (yeh oxidation hai). [short pause] Examiners yeh zaroor check karte hain ke aapne electrons correctly show kiye hain aur charges balanced hain. [enthusiasm] Yeh example bilkul perfect hai electrolysis samajhne ke liye kyunke koi complication nahi hai!	media/lectures/4_5_slide_4.mp3	2026-04-19 16:46:09.057836
53	4.5	5	Electrolysis of Aqueous Solutions	["Water complicates products in aqueous electrolysis", "Water molecules can be oxidized or reduced", "Dilute sulfuric acid produces H₂ at cathode, O₂ at anode", "Multiple ions compete for discharge at electrodes"]	[serious] Achha bacho, ab thoda complex concept aata hai lekin ghabraana nahi, main clearly samjhaata hoon. [interest] Jab hum molten compounds ka electrolysis karte hain toh seedha hai - sirf compound ke ions hote hain. [short pause] Lekin jab hum aqueous solution use karte hain matlab pani mein dissolved compound, toh pani bhi wahan present hai aur pani ke bhi apne ions hote hain! [long pause] Is wajah se situation thodi complicated ho jati hai. [soft] Pani khud bhi oxidize ya reduce ho sakta hai electrodes par, toh ab competition hai ke kaun discharge hoga. [enthusiasm] Example lete hain dilute sulfuric acid ka - H₂SO₄ solution. [interest] Is mein hydrogen ions (H⁺) hain acid se aur bhi hydrogen ions hain pani se, aur sulfate ions (SO₄²⁻) hain. [cheerful] Cathode par hydrogen ions jeet jaate hain aur reduce ho kar hydrogen gas ban jate hain - yeh gas bubbles ki tarah cathode se nikalti hai bilkul jaise Pepsi ki bottle kholte waqt bubbles nikalte hain. [short pause] Anode par situation interesting hai - sulfate ions discharge hone ki bajaye pani ke oxygen atoms oxidize hote hain aur oxygen gas banti hai. [serious] Yeh isliye hota hai kyunke pani zyada easily oxidize ho jata hai sulfate ions se. [soft] Toh cathode par H₂ gas aur anode par O₂ gas milti hai. [interest] Yeh samajhna zaroori hai ke aqueous solutions mein sirf compound ke ions nahi balke pani ke components bhi involve hote hain. [enthusiasm] Bilkul jaise bazaar mein ek customer ke liye kai dukandaar compete kar rahe hon ke mera maal kharid lo, waise hi electrodes par kai ions compete karte hain discharge hone ke liye! [serious] Exam mein agar aqueous solution ka sawaal aaye toh yaad rakho ke pani ki presence zaroor mention karni hai aur yeh explain karna hai ke kaun discharge hoga aur kyun.	media/lectures/4_5_slide_5.mp3	2026-04-19 16:46:09.057836
55	4.5	7	Industrial Applications of Electrolysis	["Extraction of aluminum from molten aluminum oxide", "Purification of copper using electrolysis", "Electroplating objects with decorative metal layers", "All processes use principle of ion discharge"]	[enthusiasm] Bacho, ab hum dekhte hain ke electrolysis industry mein kitna useful hai! [interest] Pehli application hai aluminum ka extraction. [serious] Aluminum bahut reactive metal hai toh hum ise carbon ke saath heat karke extract nahi kar sakte jaise iron karte hain. [soft] Isliye aluminum oxide ko molten karke electrolysis karte hain - is expensive process se hi pure aluminum milta hai jo planes aur cars mein use hota hai. [short pause] Doosri important application hai copper purification. [interest] Jab copper mines se nikalta hai toh impure hota hai aur humein pure copper chahiye electrical wires ke liye. [enthusiasm] Electrolysis se hum ise purify karte hain! [cheerful] Impure copper ko anode banate hain aur pure copper ki sheet ko cathode banate hain, aur copper sulfate solution mein rakhte hain. [soft] Jab current flow hota hai toh copper anode se dissolve hota hai aur cathode par pure copper deposit hota hai. [interest] Impurities neeche gir jaate hain ya solution mein reh jaate hain - bilkul jaise atta chaan-ne par bran alag ho jata hai aur fine atta milta hai. [long pause] Teesri application hai electroplating jo bahut common hai. [enthusiasm] Jab hum steel ke kisi item par silver ya chromium ki coating chaahte hain decorative purpose ke liye ya rust se bachane ke liye, toh electroplating karte hain. [cheerful] Item ko cathode banate hain aur jis metal ki coating chahiye uska anode banate hain. [soft] Jab electrolysis hota hai toh metal ions anode se dissolve hote hain aur cathode par deposit hote hain - ek thin, even layer ban jati hai. [interest] Bilkul jaise aap roti par makkhan lagaate ho evenly, waise hi electroplating mein metal ki even layer chadh jaati hai! [serious] Exam mein agar industrial applications poochen toh kam se kam teen likhni chahiye: aluminum extraction, copper purification, aur electroplating. [short pause] Aur yeh samjhana chahiye ke sabhi processes basically wohi principle use karti hain - ions ka discharge electrodes par. [soft] Yeh application-based questions O-Level mein marks lene ka achha mauka hote hain agar aap clearly explain karo.	media/lectures/4_5_slide_7.mp3	2026-04-19 16:46:09.057836
56	3.1	1	The Three States of Matter	["Matter exists in three common states: solid, liquid, and gas", "Each state has different particle arrangement and movement", "Understanding states helps explain everyday observations", "Kinetic particle theory explains all three states"]	[enthusiasm] Assalam-o-Alaikum bacho! Aaj hum chemistry ki ek bohot hi interesting topic shuru kar rahe hain - states of matter. [interest] Dekho, hamari duniya mein jo bhi cheez hai, chahe woh pani ho, chahe loha ho, chahe hawa ho, sab kuch matter hai aur yeh matter teen states mein exist karta hai. [cheerful] Pehli state hai solid jaise ke pathar ya lakri, doosri hai liquid jaise pani ya doodh, aur teesri hai gas jaise oxygen ya steam. [short pause] Ab yeh teen states bilkul alag alag kyon hain? Iska jawab hai particles ka arrangement aur unki movement. [soft] Socho jaise cricket ground mein players khade hote hain - agar sab ek line mein tight khade hon toh solid jaise, agar thoda move kar sakte hon toh liquid jaise, aur agar poore ground mein bhaag rahe hon toh gas jaise. [serious] Har state mein particles ki position aur speed different hoti hai, aur yahi difference hamein yeh samajhne mein madad karta hai ke ice solid kyon hai aur steam gas kyon hai. [enthusiasm] Yeh samajhna bohot zaroori hai kyunke har roz ki zindagi mein hum yeh dekhte hain - subah chai banate waqt pani liquid se gas banta hai, freezer mein pani solid ban jata hai. [interest] In sab observations ko explain karne ke liye scientists ne kinetic particle theory di hai. [soft] Yeh theory kehti hai ke har cheez choti choti particles se bani hai jo hamesha motion mein rehti hain. [serious] O-Level exams mein aap se poora detail ke saath ye teen states ke differences poocha jata hai, toh yeh topic thorougly prepare karna hai. [cheerful] Chaliye ab hum detail mein dekhte hain ke har state ki kya khasiyat hai!	media/lectures/3_1_slide_1.mp3	2026-04-22 16:45:54.56611
57	3.1	2	Structure and Properties of Solids	["Particles are tightly packed in regular, ordered arrangement", "Particles vibrate about fixed positions but cannot move freely", "Solids have definite shape and definite volume", "Solids are incompressible as particles are already close together"]	[interest] Pehle hum solids ke baare mein detail se samajhte hain. [enthusiasm] Jab aap ek lohe ki rod ko dekhte ho ya apni table ko touch karte ho, toh notice karo ke yeh bilkul tight aur firm hoti hai. [soft] Iska reason yeh hai ke solid mein particles bohot tightly packed hote hain, bilkul waise jaise Jummah ki namaz mein log saff bana kar khade hote hain - har banda apni jagah pe, shoulder to shoulder. [short pause] Yeh particles ek regular pattern mein arrange hote hain, matlab rows aur columns mein, aur yeh arrangement bohot ordered aur neat hoti hai. [serious] Ab yeh particles bilkul still nahin hote, inka bhi motion hai, lekin yeh motion bohot limited hai. [interest] Particles apni fixed positions ke aas paas vibrate karte rehte hain - socho jaise aap ek jagah khade ho aur thoda sa hil rahe ho lekin apni jagah nahin chod rahe. [soft] Yeh vibration hamesha hoti rehti hai, chahe temperature kitna bhi low ho, lekin particles apni position se door nahin ja sakte kyunke unke beech ke forces bohot strong hote hain. [enthusiasm] Is tight packing ki wajah se solids ko do important properties milti hain - definite shape aur definite volume. [cheerful] Matlab agar aap ek pathar ko ek glass mein rakho ya plate mein rakho, woh apni shape nahin badlega - pathar pathar hi rahega! [short pause] Aur volume bhi fixed hai - ek kilo loha hamesha utni hi jagah lega chahe aap usse kahan bhi rakho. [serious] Teesri important property hai incompressibility - yani aap solid ko dabba nahin sakte. [interest] Socho agar aap lakri ke tukde ko haath se dabbayen, woh chhota nahin hoga, kyunke particles pehle se hi bilkul close together hain, unke beech koi space hi nahin hai. [soft] Yeh bilkul waise hai jaise ek choti si shop mein bohot zyada log khade hon - aap aur logo ko andar nahin ghusa sakte kyunke pehle se hi jagah full hai. [serious] Exams mein agar solids ke properties poochen toh aapko zaroor likhna hai: particles are in fixed positions in a regular arrangement, they only vibrate, aur solid has definite shape and volume and is incompressible.	media/lectures/3_1_slide_2.mp3	2026-04-22 16:45:54.56611
58	3.1	3	Structure and Properties of Liquids	["Particles are close together but not in fixed arrangement", "Particles can move past each other, allowing flow", "Liquids have definite volume but take shape of container", "Nearly incompressible due to particles being close together"]	[enthusiasm] Ab aate hain liquids pe! [cheerful] Yeh state bohot interesting hai kyunke yeh solid aur gas ke beech mein hai - ek intermediate state. [interest] Liquids mein particles ab bhi close together hote hain jaise solid mein, lekin ab yeh fixed arrangement mein nahin hote. [soft] Matlab agar solid ek tight saff thi toh liquid ek halka sa loose gathering hai jahan log thoda idhar udhar move kar sakte hain. [short pause] Particles ke beech forces ab bhi strong hain lekin utne strong nahin jitne solid mein the. [enthusiasm] Is wajah se particles ab ek doosre ke past move kar sakte hain - yeh bohot important point hai! [interest] Socho jaise ek bazaar mein bheed ho - log ek doosre ke qareeb hain lekin apni position change kar sakte hain, ek doosre se slip kar ke aage ja sakte hain. [cheerful] Yeh movement hi liquids ko flow karne ki ability deti hai - pani glass se girata hai toh behta hai, doodh bottle se nikalta hai toh flow karta hai. [soft] Liquid apne container ki shape le leta hai kyunke particles freely move kar sakte hain aur container ki walls ke according adjust ho jate hain. [serious] Agar aap pani ko glass mein dalo toh woh glass jaisa round ho jayega, bottle mein dalo toh bottle jaisi shape le lega. [short pause] Lekin yahan ek important baat hai - shape change hoti hai lekin volume nahin! [enthusiasm] Ek liter pani chahe kisi bhi bartan mein dalo, woh ek liter hi rahega. [interest] Yeh isliye kyunke particles ab bhi quite close together hain, unke beech zyada space nahin hai. [soft] Aur yahi reason hai ke liquids bhi almost incompressible hote hain - aap pani ko dabba nahin sakte kyunke particles pehle se hi close hain. [serious] Bilkul waise jaise ek room full of people mein thodi movement possible hai lekin aap room ko compress nahin kar sakte. [cheerful] Toh yaad rakho - liquid flows kyunke particles move past each other, shape changes but volume fixed rahta hai. [serious] Exam mein clearly likhna hai: particles in liquid are close together but can move past each other, so liquid has no fixed shape but has definite volume.	media/lectures/3_1_slide_3.mp3	2026-04-22 16:45:54.56611
59	3.1	4	Structure and Properties of Gases	["Particles are spread far apart with large spaces between them", "Particles move rapidly and randomly in all directions", "Gases have no definite shape or volume, expand to fill container", "Highly compressible due to large spaces between particles"]	[enthusiasm] Ab sabse interesting state pe aate hain - gases! [cheerful] Yeh solid aur liquid se bilkul different hai. [interest] Gas mein particles bohot door door hote hain, unke beech mein bohot zyada space hota hai. [soft] Socho agar solid ek packed cricket stadium tha aur liquid ek bazaar tha, toh gas ek khula maidan hai jahan sirf kuch log hain jo bohot door door khade hain. [short pause] In particles ke beech ke forces ab bilkul weak ho chuke hain - almost negligible. [enthusiasm] Is wajah se particles ab completely freely move kar sakte hain aur woh bhi bohot tez speed se! [interest] Yeh particles randomly har direction mein move karte hain - koi upar ja raha hai, koi neeche, koi left, koi right, bilkul koi pattern nahin. [cheerful] Aur jab yeh move karte hain toh ek doosre se collide bhi hote rehte hain, aur container ki walls se bhi takrate hain. [soft] Yeh collisions hi gas ka pressure create karte hain - jab particles walls se takrate hain toh force lagata hai. [serious] Ab kyunke particles itne door hain aur freely move kar rahe hain, gas ki koi fixed shape nahin hoti aur na hi koi fixed volume. [enthusiasm] Agar aap kisi gas ko ek balloon mein bharo toh woh balloon ki shape le lega, tank mein bharo toh tank jaisi ho jayegi. [interest] Aur agar container ki size change karo, toh gas expand ya contract karke poori jagah fill kar lega. [soft] Yeh bilkul waise hai jaise agar ek kamre mein agarbatti jalao toh uski smell poore kamre mein phail jati hai - gas particles expand karke sara space fill kar lete hain. [serious] Sabse important property hai compressibility - gases ko bohot easily compress kiya ja sakta hai. [enthusiasm] Socho CNG cylinder mein - bohot zyada gas ko dabba kar choti si cylinder mein fit kar dete hain! [interest] Yeh possible hai kyunke particles ke beech itna space hai ke aap unhe aur qareeb la sakte ho. [cheerful] Bilkul jaise ek bade ground mein thode log khade hon toh aap unhe ek choti jagah mein ikattha kar sakte ho. [serious] Exam mein gases ke liye likhna hai: particles are far apart with large spaces, they move rapidly and randomly, gas has no fixed shape or volume, and gases are highly compressible. [soft] Yeh teen states ki understanding O-Level mein bohot marks deti hai toh ache se revise karna.	media/lectures/3_1_slide_4.mp3	2026-04-22 16:45:54.56611
60	3.1	5	Kinetic Particle Theory Explained	["All matter is made up of tiny particles in constant motion", "Higher temperature means greater kinetic energy and faster movement", "State depends on balance between kinetic energy and intermolecular forces", "Theory explains diffusion, pressure, and changes of state"]	[enthusiasm] Ab aate hain kinetic particle theory pe jo in sab states ko explain karti hai! [interest] Yeh theory chemistry ki foundation hai aur bohot important hai O-Level ke liye. [serious] Is theory ki pehli baat yeh hai ke sab kuch - solid, liquid, gas - sab tiny particles se bana hai aur yeh particles hamesha motion mein rehte hain. [soft] Haan, even solids mein bhi particles move karte hain, bas unki movement limited hai. [short pause] Yeh particles itne chote hote hain ke hum unhe naked eye se nahin dekh sakte, lekin yeh exist karte hain aur constantly motion mein hain. [cheerful] Ab doosri important baat - temperature ka connection kinetic energy se. [enthusiasm] Jab aap kisi cheez ko heat karte ho, matlab uska temperature barhaate ho, toh us cheez ke particles ki kinetic energy barh jati hai. [interest] Kinetic energy matlab movement energy - jitni zyada energy utni tezi se particles move karenge. [soft] Socho jaise garmi mein log jaldi jaldi chalne lagte hain aur thandi mein slow ho jate hain - exactly waise hi particles behave karte hain temperature ke saath. [serious] Jab aap pani ko garam karte ho, toh pani ke particles zyada tezi se move karne lagte hain, zyada energy milti hai unhe. [short pause] Ab teesra aur sabse important point - state kisse decide hoti hai? [enthusiasm] State decide hoti hai do cheezon ke balance se: particles ki kinetic energy aur particles ke beech ki forces yani intermolecular forces. [interest] Agar kinetic energy kam hai aur intermolecular forces strong hain, toh particles apni jagah pe rahenge - solid banega. [soft] Agar kinetic energy thodi barh gayi aur forces thode weak ho gaye, toh particles thoda move kar sakte hain - liquid ban jati hai. [cheerful] Aur jab kinetic energy bohot zyada ho jaye aur overcome kar le intermolecular forces ko, toh particles bilkul free ho jate hain - gas ban jati hai. [serious] Yeh bilkul waise hai jaise agar aap rassi se bandhe ho (intermolecular forces) aur aapko bhagne ki taqat mil jaye (kinetic energy), toh aap rassi todh kar free ho jaoge. [enthusiasm] Is theory se hum bohot sari properties explain kar sakte hain! [interest] Diffusion explain ho jata hai - perfume ki smell phailti hai kyunke gas particles randomly move karte hain. [soft] Pressure explain ho jata hai - gas particles container ki walls se takrate hain toh pressure create hota hai. [cheerful] Aur changes of state bhi explain ho jate hain - jab ice ko heat karo toh particles ki energy barhti hai aur solid liquid ban jata hai. [serious] Examiners is theory ke applications bohot poochte hain, toh examples ke saath seekho. [short pause] Likhna seekho: kinetic particle theory states that all matter consists of particles in constant motion, and temperature affects their kinetic energy which determines the state of matter.	media/lectures/3_1_slide_5.mp3	2026-04-22 16:45:54.56611
61	3.1	6	Comparing the Three States	["Solid: ordered arrangement, vibration only, definite shape and volume", "Liquid: random arrangement, particles slide past each other, definite volume only", "Gas: particles far apart, rapid random motion, no definite shape or volume", "All differences explained by particle arrangement and energy"]	[cheerful] Ab hum teen states ka comparison karte hain taake difference achhi tarah clear ho jaye! [enthusiasm] Yeh comparison table ki tarah hai jo exams mein bohot kaam aata hai. [serious] Sabse pehle solids ko dekho - inka arrangement ordered hai, matlab particles rows aur columns mein line se khade hain. [soft] Movement sirf vibration hai, ek jagah pe hi thoda hilna, aur yeh vibration bhi fixed positions ke around hai. [interest] Is wajah se solid ki shape aur volume dono definite hain - ek iron rod apni shape nahin badlega chahe aap use kahan rakho. [short pause] Ab liquid ko dekho - arrangement ab ordered nahin rahi, particles randomly placed hain lekin ab bhi close together. [cheerful] Movement ab zyada ho gayi - particles ab ek doosre ke past slip kar sakte hain, slide kar sakte hain. [enthusiasm] Yeh sliding motion hi liquid ko flow karne deta hai! [soft] Lekin kyunke particles ab bhi close hain, isliye volume toh definite hai, sirf shape change hoti hai container ke according. [interest] Bilkul jaise lassi ya doodh - glass mein dalo toh glass jaisi, jug mein dalo toh jug jaisi shape le le. [serious] Ab gas pe aao - yahan scene bilkul alag hai! [enthusiasm] Particles bohot door door hain, arrangement ka toh sawaal hi nahin, sab randomly placed aur constantly moving. [cheerful] Aur yeh movement bhi kya movement hai - rapid aur random, har direction mein tezi se! [interest] Particles ek doosre se dur hain toh unhe koi rok nahin raha, bas move karte raho. [soft] Is wajah se gas na shape fix kar sakti hai na volume - jo container milo us mein expand karke bhar jao. [short pause] Agar chota container ho toh compress ho jao, bada ho toh expand ho jao. [serious] In sab differences ki ek hi wajah hai - particles ka arrangement aur unki energy. [enthusiasm] Solid mein particles ki energy kam hai aur forces strong, liquid mein energy medium hai aur forces moderate, gas mein energy bohot zyada hai aur forces weak. [interest] Yeh understanding bohot zaroori hai kyunke exams mein aap se comparison questions aate hain. [cheerful] For example: Compare and contrast the arrangement and movement of particles in solids and gases - aapko dono states batani hain side by side. [serious] Hamesha likhna: solids have particles in fixed regular arrangement with vibration only, while gases have particles far apart with rapid random motion. [soft] Aur yeh mat bhoolo ke reasons bhi dena hai - kyunke intermolecular forces aur kinetic energy different hain. [short pause] Aise detailed answers se aapko full marks milte hain!	media/lectures/3_1_slide_6.mp3	2026-04-22 16:45:54.56611
62	2.3	1	What is Electronic Configuration?	["Electronic configuration describes the arrangement of electrons in shells around the nucleus", "Electrons occupy shells in order of increasing energy levels", "Innermost shells are filled first before moving to outer shells"]	[enthusiasm] Assalam-o-alaikum bachon! Aaj hum ek bohot hi interesting aur important topic shuru kar rahe hain - Electronic Configuration. [soft] Dekho, har atom ke andar nucleus hota hai center mein, aur us ke around electrons ghoomte rehte hain different shells mein. [interest] Electronic configuration ka matlab hai ke yeh electrons kis tarah se arrange hote hain in shells mein - bilkul waise jaise aapke ghar mein different rooms mein log rehte hain, waise hi electrons bhi apne fixed shells mein rehte hain. [short pause] Yeh arrangement random nahi hoti, balke ek proper pattern follow karti hai. [cheerful] Socho agar aapki ammi chai bana rahi hain - pehle paani dalti hain, phir chai patti, phir cheeni - ek order hai na? [enthusiasm] Waise hi electrons bhi ek specific order mein shells fill karte hain. [serious] Shells ko energy levels bhi kehte hain kyunke har shell ki apni energy hoti hai. [soft] Jo shell nucleus ke zyada qareeb hota hai uski energy kam hoti hai, aur jo door hota hai uski energy zyada hoti hai. [interest] Ab electrons hamesha pehle kam energy wali shell ko fill karte hain, phir baad mein high energy wali shells ki taraf move karte hain. [short pause] Is ko hum kehte hain 'order of increasing energy' - matlab energy ke hisaab se choti se badi taraf. [serious] Pehle innermost shell yani sabse andar wali shell completely fill hogi, tab jaake electrons next shell mein jaayenge. [enthusiasm] Bilkul waise jaise pehle ground floor ki rooms fill honge, phir first floor ki - koi directly first floor pe nahi jaa sakta jab tak ground floor full na ho! [cheerful] Yeh rule bahut important hai chemistry mein, aur exam mein bhi zaroor aata hai. [serious] Examiner yeh dekhta hai ke aap electrons ko sahi order mein arrange kar rahe ho ya nahi, toh yeh concept ache se samajh lo.	media/lectures/2_3_slide_1.mp3	2026-04-22 17:14:11.663115
63	2.3	2	Maximum Electrons in Each Shell	["First shell can hold maximum 2 electrons only", "Second shell can hold up to 8 electrons", "Third shell can hold up to 8 electrons for first 20 elements"]	[serious] Ab bachon, har shell ki ek limit hoti hai ke wo kitne electrons rakh sakti hai. [interest] Yeh bilkul waise hai jaise ek rickshaw mein sirf 3-4 log baith sakte hain, bus mein zyada baith sakte hain - har cheez ki capacity hoti hai. [enthusiasm] Pehli shell jo nucleus ke bilkul qareeb hoti hai, wo sabse choti shell hai aur sirf 2 electrons hi rakh sakti hai - bas 2, aur koi nahi! [soft] Yeh shell ko hum K shell bhi kehte hain. [short pause] Is mein zyada jagah nahi hoti kyunke yeh bohot choti hoti hai. [cheerful] Socho jaise mobile phone mein pehle sirf 2G memory card aata tha chota sa - waise hi pehli shell choti si hai. [interest] Ab doosri shell jo biraz door hoti hai nucleus se, wo zyada badi hai aur 8 electrons tak rakh sakti hai. [enthusiasm] 2 se seedha 8 - yeh ek bari jump hai capacity mein! [soft] Is shell ko L shell bhi kehte hain. [serious] Teesri shell bhi 8 electrons rakh sakti hai, lekin sirf pehle 20 elements ke liye jinka hum O-Level mein study karte hain. [short pause] Actually teesri shell 18 tak rakh sakti hai lekin wo baad mein aata hai advanced chemistry mein. [interest] Filhaal aapko yaad rakhna hai: 2, 8, 8 - yeh teen numbers bohot important hain. [cheerful] Main batati hoon ek trick: 'Do Aath Aath' - jaise aap do din mein aath aath ghante padhte ho! [laughs] [serious] Exam mein agar kisi element ka electronic configuration likhna ho toh pehle yeh limits zaroor yaad rakho. [soft] Examiner dekhta hai ke aapne kisi shell mein uski capacity se zyada electrons toh nahi daal diye - yeh common mistake hai jo marks kaat deti hai. [enthusiasm] Toh bachon, yeh capacity limits ache se yaad kar lo aur practice karte raho!	media/lectures/2_3_slide_2.mp3	2026-04-22 17:14:11.663115
64	2.3	3	Electronic Configuration: First 20 Elements	["Hydrogen (1 electron): 1 | Helium (2 electrons): 2", "Lithium (3 electrons): 2,1 | Neon (10 electrons): 2,8", "Sodium (11 electrons): 2,8,1 | Argon (18 electrons): 2,8,8 | Calcium (20 electrons): 2,8,8,2"]	[enthusiasm] Chalo bachon, ab hum kuch examples dekhen ge actual elements ke. [soft] Sabse pehla element hai Hydrogen - yeh sabse simple hai kyunke is mein sirf 1 electron hai. [interest] Toh iska configuration likhenge: 1 - bilkul simple, pehli shell mein ek electron. [cheerful] Helium mein 2 electrons hain toh configuration hai: 2 - matlab pehli shell ab full ho gayi! [short pause] Ab dekho Lithium mein 3 electrons hain. [serious] Pehli shell sirf 2 le sakti hai toh pehle 2 daalo, phir teesra electron doosri shell mein jaayega. [enthusiasm] Toh Lithium ka configuration hoga: 2,1 - do pehli shell mein, ek doosri shell mein. [interest] Bilkul jaise agar aapke paas 3 rotiyaan hain aur pehli plate mein sirf 2 hi aa sakti hain, toh teesri doosri plate mein rakhni paregi! [soft] Neon ek special element hai jis mein 10 electrons hain. [cheerful] Is ka configuration hai: 2,8 - pehli shell full, doosri shell bhi full! [enthusiasm] Yeh complete configuration hai, bilkul perfect balance. [serious] Sodium mein 11 electrons hain toh dekho kaise fill hoga: pehle 2, phir 8, phir 1 bacha toh wo teesri shell mein - configuration: 2,8,1. [short pause] Argon mein 18 electrons hain aur sab shells properly fill hain: 2,8,8 - yeh bhi complete configuration hai. [interest] Calcium last element hai jo hum study karte hain, is mein 20 electrons hain: pehli shell 2, doosri 8, teesri 8, aur 2 bache toh chauthi shell mein - configuration: 2,8,8,2. [soft] Ab dekho ek pattern: jaise jaise electrons barh rahe hain, shells bhi fill hoti ja rahi hain ek ke baad ek. [serious] Exam mein sabse zyada yeh configuration hi poochhe jaate hain pehle 20 elements ke. [enthusiasm] Examiner check karta hai ke aapne shells sahi order mein fill ki hain aur kisi shell ki capacity se zyada toh nahi daal diya. [cheerful] Meri nasihat hai ke in common elements ka configuration ratta maar lo - Hydrogen se Calcium tak - yeh bohot kaam aayega!	media/lectures/2_3_slide_3.mp3	2026-04-22 17:14:11.663115
65	2.3	4	Electronic Configuration and the Periodic Table	["Period number equals the number of electron shells in an element", "Group number indicates the number of valence electrons in outer shell", "Elements in same group have similar chemical properties due to same valence electrons"]	[interest] Bachon, ab hum dekhen ge ke electronic configuration ka periodic table se kya connection hai. [enthusiasm] Yeh bohot interesting connection hai aur exam mein zaroor questions aate hain is pe! [soft] Dekho, periodic table mein horizontal rows hoti hain jinhe hum periods kehte hain - Period 1, Period 2, Period 3. [serious] Ab yeh period number tumhe direct bata deta hai ke us element mein kitni shells hain. [interest] Matlab agar koi element Period 3 mein hai, toh us ke paas 3 electron shells hongi - bilkul direct connection! [cheerful] Socho jaise school mein agar koi Class 9 mein hai toh usne 9 saal school mein guzare hain - waise hi Period 3 matlab 3 shells. [short pause] For example, Sodium Period 3 mein hai aur uska configuration hai 2,8,1 - dekho 3 shells hain na? [enthusiasm] Ab groups ki baat karte hain - yeh vertical columns hoti hain periodic table mein. [soft] Group number tumhe bata deta hai ke outermost shell mein kitne electrons hain, jinhe hum valence electrons kehte hain. [interest] Valence electrons wo hote hain jo reactions mein part lete hain - yeh bohot important hote hain chemistry mein. [serious] Group 1 ke sab elements mein outer shell mein 1 electron hota hai - jaise Lithium: 2,1 aur Sodium: 2,8,1 - dekho dono ki outer shell mein 1 electron hai! [short pause] Group 2 mein outer shell mein 2 electrons, Group 7 mein 7 electrons outer shell mein hote hain. [enthusiasm] Ab sabse interesting baat yeh hai ke same group ke elements ka chemical behavior bhi same hota hai! [cheerful] Bilkul jaise ek family ke bhai-behan ki habits milti julti hoti hain, waise hi same group ke elements ki properties bhi similar hoti hain. [soft] Aur yeh sab kuch sirf valence electrons ki wajah se hota hai. [serious] Examiner bohot bar poochta hai: 'Why do elements in same group show similar properties?' - jawab hai: 'Because they have same number of valence electrons in their outer shell.' [interest] Toh periodic table ko electronic configuration se jorna seekh lo, yeh bohot useful hai!	media/lectures/2_3_slide_4.mp3	2026-04-22 17:14:11.663115
66	2.3	5	Noble Gases: Completely Filled Shells	["Group 0 or Group 18 elements are called noble gases", "Noble gases have completely filled outer shells making them stable", "Complete outer shells explain their chemical inertness and non-reactivity"]	[enthusiasm] Bachon, ab hum baat karte hain ek bohot special group ki - Noble Gases! [cheerful] Inhe noble isliye kehte hain kyunke yeh kisi ke saath react nahi karte, bilkul jaise koi nawab jo kisi se milta nahi! [laughs] [soft] Yeh Group 0 ya Group 18 mein aate hain periodic table ke last column mein. [interest] In mein aate hain: Helium, Neon, Argon, Krypton - yeh sab gases hain aur bohot special hain. [serious] Ab sawaal yeh hai ke yeh itne special kyun hain? [short pause] Jawab hai inki electronic configuration mein. [enthusiasm] Dekho Helium ka configuration: 2 - pehli shell completely full! [soft] Neon ka configuration: 2,8 - pehli aur doosri dono shells full! [interest] Argon ka configuration: 2,8,8 - teen shells, teeno full! [cheerful] Socho agar aapke mobile ka battery full charged ho 100%, toh aapko charger ki zaroorat nahi hoti na? [enthusiasm] Waise hi jab kisi element ki outer shell completely full ho, toh use aur electrons ki zaroorat nahi hoti! [soft] Is complete configuration ko hum 'stable configuration' kehte hain - yeh bohot stable aur satisfied hote hain. [serious] Ab kyunke yeh already satisfied hain, toh yeh kisi aur element ke saath react kyun karenge? [short pause] Inhe na electrons chahiye, na yeh electrons dena chahte hain kisi ko. [interest] Is wajah se noble gases chemically inert hote hain - matlab bilkul non-reactive, kisi se combination nahi banate. [soft] Bazaar mein dekho jo dukandaar bohot ameer ho, wo har customer se deal nahi karta kyunke uski zaroorat nahi - waise hi noble gases 'ameer' hain electrons se, toh react nahi karte! [serious] Exam mein agar poochha jaye: 'Why are noble gases unreactive?' - toh likhna hai: 'Because they have completely filled outer shells, making them stable and chemically inert.' [enthusiasm] Yeh concept bohot important hai bachon, aur aage chalke bonding samajhne mein bhi kaam aayega. [cheerful] Noble gases ke configuration yaad rakho - yeh standard bante hain jis ki taraf baaki sab elements jaana chahte hain!	media/lectures/2_3_slide_5.mp3	2026-04-22 17:14:11.663115
67	2.3	6	Ion Formation: Metals Losing Electrons	["Metal atoms lose electrons from outermost shell to form positive ions", "Sodium (2,8,1) loses 1 electron to form Na⁺ with configuration 2,8", "After losing electrons, metal ions achieve stable noble gas configuration"]	[serious] Ab bachon, hum dekhenge ke electronic configuration ka ions banane se kya taalluk hai. [interest] Pehle metals ki baat karte hain - yeh electrons lose karte hain. [soft] Metal atoms apni outermost shell se electrons nikaal dete hain taake stable ho jayein. [enthusiasm] Ab yeh samajhna bohot zaroori hai ke kyun karte hain aisa! [short pause] Dekho, har element ko noble gas jaise banna hai kyunke wo bohot stable hote hain. [cheerful] Bilkul jaise har student chaahta hai ke wo topper jaise ban jaye - waise hi har atom chaahta hai noble gas jaise stable ban jaye! [interest] Sodium ko example lete hain - iska configuration hai 2,8,1. [soft] Ab dekho outer shell mein sirf 1 electron hai, aur Sodium ko stable hona hai. [serious] Ab do raaste hain: ya toh 7 aur electrons le lo outer shell ko 8 karne ke liye, ya phir 1 electron de do taake pichhli wali shell 2,8 bach jaye. [short pause] Konsa asaan hai? [enthusiasm] Obviously 1 dena zyada asaan hai 7 lene se! [cheerful] Bilkul jaise agar aapke paas ek extra roti hai aur aap satisfied hona chahte ho, toh wo ek roti kisi ko de do, bajaye ke 7 aur rotiyaan maango! [laughs] [interest] Toh Sodium apna 1 electron lose kar deta hai aur ban jata hai Na⁺ ion - yeh + sign dikhata hai ke ek electron chala gaya. [soft] Ab Na⁺ ka configuration ho gaya: 2,8 - yeh bilkul Neon jaisa hai jo noble gas hai! [enthusiasm] Dekho kitna smart move hai - ek electron dekar Sodium ne stable noble gas configuration hasil kar liya. [serious] Yeh positive ion ban gaya kyunke electron negatively charged hota hai, jab wo nikal gaya toh protons zyada ho gaye electrons se. [short pause] Is process ko hum kehte hain 'oxidation' aur metal ko 'cation' kehte hain. [interest] Exam mein agar poochha jaye metal ion kaise banta hai, toh clearly likhna hai: metal loses electron(s) from outer shell to achieve noble gas configuration aur positive ion banta hai. [serious] Examiner yeh dekh raha hota hai ke aap reason bhi de rahe ho saath mein - sirf process nahi, 'why' bhi zaroor likho!	media/lectures/2_3_slide_6.mp3	2026-04-22 17:14:11.663115
68	2.3	7	Ion Formation: Non-Metals Gaining Electrons	["Non-metal atoms gain electrons in outermost shell to form negative ions", "Chlorine (2,8,7) gains 1 electron to form Cl⁻ with configuration 2,8,8", "After gaining electrons, non-metal ions achieve stable noble gas configuration"]	[interest] Ab bachon, non-metals ki baat karte hain - yeh opposite karte hain metals se. [soft] Non-metals electrons gain karte hain apni outer shell mein. [enthusiasm] Yeh electrons leta hai taake apni outer shell complete kar sake aur stable ho jaye! [serious] Chlorine ka example lete hain - bohot important element hai aur exam mein bhi bohot aata hai. [short pause] Chlorine ka configuration hai: 2,8,7. [interest] Ab dekho outer shell mein 7 electrons hain, aur complete shell ke liye 8 chahiye. [cheerful] Matlab sirf 1 electron ki kami hai - bilkul jaise cricket match mein agar 1 run chahiye jeetne ke liye toh aap zaroor loge na? [enthusiasm] Waise hi Chlorine 1 electron le leta hai! [soft] Ab Chlorine kehta hai ke main 7 electrons dunga ya 1 electron lunga? [serious] Obviously 1 lena bohot asaan hai - toh Chlorine 1 electron gain kar leta hai. [interest] Jab electron gain ho jata hai toh Chlorine ban jata hai Cl⁻ ion - yeh minus sign dikhata hai ke ek extra electron aa gaya. [short pause] Ab Cl⁻ ka configuration ho gaya: 2,8,8 - yeh bilkul Argon jaisa hai jo noble gas hai! [enthusiasm] Dekha? Chlorine ne bhi wo hi kiya jo uske liye sabse asaan tha - 1 electron leke stable noble gas configuration hasil kar liya. [cheerful] Socho bijli ka bill - agar aapko 100 rupay dene hain aur aapke paas 99 rupay hain, toh aap 1 rupay le loge ya 99 wapas karke 100 naye maangoge? [laughs] Obviously 1 hi loge! [soft] Yeh negative ion ban gaya kyunke electron negatively charged hota hai, jab extra electron aa gaya toh electrons zyada ho gaye protons se. [serious] Is process ko hum kehte hain 'reduction' aur non-metal ion ko 'anion' kehte hain. [interest] Yeh trend yaad rakho: metals lose electrons, non-metals gain electrons - dono ka maqsad ek hi hai: noble gas configuration hasil karna! [short pause] Exam mein agar Chlorine ion ki formation poochhi jaye toh step by step likho: pehle original configuration, phir electron gain, phir final configuration noble gas ke barabar. [serious] Examiner dekhta hai ke aapko reason pata hai ke kyun non-metal electron gain karta hai - 'to achieve stable noble gas configuration' yeh phrase zaroor use karo!	media/lectures/2_3_slide_7.mp3	2026-04-22 17:14:11.663115
69	2.3	8	Valence Electrons Determine Chemical Reactivity	["Number of valence electrons determines how an element will react", "Metals lose electrons, non-metals gain electrons, and some elements share electrons", "Achieving noble gas configuration drives most chemical reactions"]	[enthusiasm] Bachon, ab hum sab concepts ko ek saath jorne wale hain! [serious] Poori chemistry mein sabse important baat yeh hai ke valence electrons decide karte hain ke element kaisa react karega. [interest] Valence electrons wo hote hain jo outer shell mein hote hain - yeh hi sab kaam karte hain reactions mein. [soft] Andar ki shells ke electrons toh bas baithe rehte hain, bahar wale hi active hote hain. [cheerful] Bilkul jaise ghar ke andar wale buzurg bas ghar mein rehte hain, bahar ka kaam bachhe karte hain jo active hote hain! [short pause] Ab dekho teen tareeqe hain reactivity ke. [enthusiasm] Pehla: Metals jo outer shell mein kam electrons rakhte hain (1, 2, ya 3), yeh electrons lose kar dete hain kyunke unhe positive ions banana asaan hota hai. [interest] Group 1 mein 1 valence electron, Group 2 mein 2 valence electrons - yeh sab lose karna prefer karte hain. [soft] Doosra tareeqa: Non-metals jo outer shell mein zyada electrons rakhte hain (5, 6, ya 7), yeh electrons gain kar lete hain kyunke inhe bas thore electrons chahiye complete hone ke liye. [serious] Group 7 mein 7 valence electrons hain toh sirf 1 gain karna hai - yeh bohot reactive hote hain! [short pause] Teesra tareeqa: Kuch elements na easily lose kar sakte hain na easily gain - toh yeh electrons share kar lete hain dusre atoms ke saath. [interest] Is sharing ko hum covalent bonding kehte hain - yeh bhi achieve karta hai stable configuration. [enthusiasm] Ab sab ke peeche ek hi reason hai - sab ko noble gas configuration chahiye! [cheerful] Yeh noble gas configuration jaise ek manzil hai jis tak pahunchne ke teen raste hain: lose karo, gain karo, ya share karo! [soft] Har element apne liye sabse asaan rasta choose karta hai apne valence electrons dekh kar. [serious] Toh samajh lo ke chemistry mein noble gas configuration hi wo target hai jo har element chahta hai, aur electronic configuration batata hai ke wo kaunsa rasta choose karega. [interest] Exam mein agar reactivity ka sawaal aaye toh pehle outer shell ke electrons dekho, phir decide karo ke element lose karega, gain karega, ya share karega. [short pause] Examiner yeh bhi check karta hai ke aap yeh bata sako ke kyun ek element metal ki tarah behave karta hai ya non-metal ki tarah - jawab hai valence electrons ki number mein! [enthusiasm] Yeh poora concept clear ho jaye toh chemistry ki aadhi mushkil hal ho jaati hai, bachon!	media/lectures/2_3_slide_8.mp3	2026-04-22 17:14:11.663115
70	3.2	1	What Are Changes of State?	["Change of state is a physical change between solid, liquid and gas", "Six changes of state: melting, freezing, evaporation, condensation, sublimation, deposition", "Physical change means no new substance is formed, only state changes", "Temperature and energy determine which state a substance exists in"]	[enthusiasm] Assalam-o-Alaikum bacho! Aaj hum ek bohot interesting topic shuru kar rahe hain - changes of state. [interest] Dekho, humein pata hai ke matter ki teen states hain: solid, liquid aur gas. Lekin kya aap jaante hain ke yeh states fixed nahi hain? [cheerful] Bilkul waise jaise ghar mein hum pani ko ice bana sakte hain freezer mein, ya chai ko garam kar ke steam ban jata hai! [short pause] Ab sabse pehli important baat yeh hai ke change of state ek physical change hai, chemical change nahi. Is ka matlab yeh hai ke substance ki chemical composition same rehti hai - sirf uski state badal rahi hai. [soft] Maan lo aap ke paas pani hai - usay ice bana do ya steam bana do, woh pani hi rahega, H2O hi rahega, koi naya substance nahi banega. [enthusiasm] Ab dekho, total chhe changes of state hain jinko hum detail mein parrhenge: melting, freezing, evaporation, condensation, sublimation aur deposition. [interest] Har change ka apna naam hai aur har ek specific direction mein hota hai - solid se liquid, liquid se gas, waghaira. [serious] Exam mein agar poochha jaye ke change of state kya hai, toh clearly likhna hai: it is a physical change in which a substance transforms from one state to another without changing its chemical composition. [short pause] Ab yeh samajhna bhi zaroori hai ke kaunsi state mein substance exist karega, yeh temperature aur energy par depend karta hai. [soft] Jaise Pakistan mein garmiyon mein ice cream jaldi pighal jati hai kyunke temperature zyada hai, aur sardiyon mein pani thanda ho kar jaldi jam sakta hai. [enthusiasm] Toh temperature aur energy woh do factors hain jo decide karte hain ke koi substance kis state mein rahega. Yeh concept aage bohot kaam aayega!	media/lectures/3_2_slide_1.mp3	2026-04-22 17:57:41.033642
71	3.2	2	Melting and Freezing Processes	["Melting: solid changes to liquid when heated to melting point", "Freezing: liquid changes to solid when cooled to freezing point", "Melting point and freezing point are the same temperature for a pure substance", "These are reverse processes of each other"]	[interest] Chalo ab hum pehle do changes of state ko detail mein samajhte hain - melting aur freezing. [enthusiasm] Melting woh process hai jab aap kisi solid ko heat karte hain aur woh liquid ban jata hai. [cheerful] Bilkul jaise ghar mein makkhan roti par rakho toh garam roti ki wajah se woh pighal kar liquid ho jata hai! [short pause] Har substance ka apna specific melting point hota hai - woh temperature jis par woh melt hona shuru ho jata hai. [soft] Ice ka melting point 0°C hai, matlab zero degree par ice pighal kar pani ban jata hai. Lead ka melting point 327°C hai, iron ka bohot zyada 1538°C hai. [serious] Yeh melting points har substance ke liye different hote hain aur yeh characteristic properties hain jinse hum substances ko identify kar sakte hain. [interest] Ab freezing exactly opposite process hai melting ki. Jab aap liquid ko thanda karte hain, toh woh solid ban jata hai. [soft] Jaise freezer mein pani rakh do toh woh ice ban jata hai - yeh freezing hai. [enthusiasm] Ab yahan ek bohot important point hai jo students aksar confuse ho jate hain! [serious] Melting point aur freezing point dono same temperature hote hain kisi bhi pure substance ke liye. [short pause] Matlab pani 0°C par freeze bhi hota hai aur ice 0°C par melt bhi hota hai - same temperature! [interest] Yeh dono processes ek doosre ke reverse hain, bilkul jaise cricket match mein agar Pakistan India ko harata hai, aur phir India Pakistan ko harata hai - opposite directions. [soft] Ek mein solid se liquid ja rahe hain, doosre mein liquid se solid. [serious] Exam mein agar definition pucho toh clearly likhna: melting is the change from solid to liquid at the melting point when heated, and freezing is the reverse change from liquid to solid at the same temperature when cooled.	media/lectures/3_2_slide_2.mp3	2026-04-22 17:57:41.033642
72	3.2	3	Evaporation and Boiling: Two Different Processes	["Evaporation: liquid to gas at surface only, occurs below boiling point at any temperature", "Boiling: liquid to gas throughout the liquid, occurs at specific boiling point temperature", "Evaporation happens because some surface particles have enough energy to escape", "Boiling produces bubbles of vapor throughout the entire liquid"]	[enthusiasm] Bacho, yeh slide bohot important hai kyunke exam mein aksar yeh question aata hai - evaporation aur boiling mein kya difference hai! [interest] Dono processes mein liquid gas ban raha hai, lekin dono bilkul different hain. [soft] Pehle evaporation ko samajhte hain. Evaporation sirf liquid ki surface par hota hai, andar nahi. [cheerful] Jaise ghar mein aap ne geele kapray bahar sukhane ke liye daal diye - dhoop mein ya hawa mein woh sukh jaate hain. Yeh evaporation hai! [short pause] Ab interesting baat yeh hai ke evaporation kisi bhi temperature par ho sakta hai, boiling point se neeche bhi. [soft] Matlab room temperature par bhi kapray sukh sakte hain, pani evaporate ho sakta hai. [interest] Aisa isliye hota hai kyunke liquid ki surface par kuch particles ke paas zyada energy hoti hai - woh escape kar ke gas ban jate hain. [enthusiasm] Bilkul waise jaise bazaar mein bohot bheer hai, lekin kuch log jo edge par khare hain woh nikal sakte hain easily, beech wale nahi nikal sakte! [short pause] Ab boiling ko dekho - yeh bilkul alag hai. Boiling mein pure liquid ke andar se bubbles bantay hain aur poori liquid gas ban rahi hoti hai. [serious] Boiling sirf ek specific temperature par hoti hai jo boiling point kehlata hai. Pani ke liye yeh 100°C hai at normal pressure. [interest] Jab aap chai banate hain aur pani uchhal raha hota hai bubbles ke saath, woh boiling hai. Poori liquid ke andar se vapor ban raha hota hai. [soft] Evaporation mein sirf upar ki surface se particles escape karte hain, boiling mein poori liquid se. [serious] Exam mein agar yeh question aaye toh clearly difference likhna: evaporation occurs at the surface only at any temperature below boiling point, while boiling occurs throughout the liquid at a specific temperature called boiling point, producing bubbles.	media/lectures/3_2_slide_3.mp3	2026-04-22 17:57:41.033642
73	3.2	4	Condensation and Sublimation	["Condensation: gas changes to liquid when cooled (reverse of evaporation)", "Sublimation: solid changes directly to gas without becoming liquid", "Deposition: gas changes directly to solid (reverse of sublimation)", "Example: dry ice (solid CO₂) sublimates at room temperature"]	[interest] Ab hum baki ke changes of state dekhte hain. Condensation woh process hai jab gas thanda ho kar liquid ban jata hai. [soft] Yeh evaporation ka exactly opposite hai. [cheerful] Subah jab aap uthte hain aur ghar ki khirkiyon par ya glass par pani ki choti choti boondein dekhi hain? Woh condensation hai! [enthusiasm] Hawa mein water vapors thay jo raat ko glass ki thandi surface par cool ho kar pani ki boondein ban gaye. [short pause] Ya phir garmiyon mein jab aap fridge se thandi bottle nikalte hain, uski surface par paani aa jata hai - yeh bhi condensation hai. Hawa ki water vapors thandi bottle ko touch karke liquid ban gayi. [interest] Ab ek bohot interesting process hai sublimation. [serious] Is mein solid seedha gas ban jata hai, beech mein liquid state mein aata hi nahi! [enthusiasm] Yeh sunn kar ajeeb lagta hai na, ke liquid phase skip ho gaya? Lekin yeh hota hai! [cheerful] Sabse famous example hai dry ice - yeh solid carbon dioxide hai. [soft] Room temperature par agar aap dry ice rakho, toh yeh pighal kar liquid nahi banta, seedha gas ban jata hai - ek white smoke type dikhayi deta hai. [interest] Pakistan mein kabhi kabhi ice cream delivery ya special events mein dry ice use hote dekha hai? Woh yahi kar raha hota hai - sublime ho raha hota hai. [short pause] Naphthalene balls jo moths se bachane ke liye use hoti hain, woh bhi slowly sublime hoti hain - solid se gas ban jati hain without melting. [soft] Deposition sublimation ka opposite hai - jab gas seedha solid ban jaye bina liquid bane. [serious] Exam mein agar sublimation ki definition poochhi jaye toh likhna: sublimation is the direct change from solid to gas without passing through the liquid state. Example zaroor dena: dry ice or naphthalene.	media/lectures/3_2_slide_4.mp3	2026-04-22 17:57:41.033642
74	3.2	5	Energy Changes During State Changes	["Energy must be supplied to melt or evaporate a substance (endothermic)", "Energy is released when freezing or condensing occurs (exothermic)", "This energy is used to overcome forces between particles", "Breaking particle forces requires energy input, forming forces releases energy"]	[serious] Ab hum bohot important concept par aaye hain - energy changes. [interest] Har change of state mein energy ka involvement hota hai, bina energy ke koi change nahi ho sakta. [enthusiasm] Dekho, jab aap kisi substance ko melt karna chahte hain ya evaporate karna chahte hain, toh aapko energy supply karni parti hai. [soft] Isliye ice ko pighlane ke liye hum heat karte hain, pani ko boil karne ke liye stove par rakhte hain - energy de rahe hote hain. [interest] Aise processes jinme energy supply karni parti hai unhein hum endothermic processes kehte hain. [short pause] Ab yeh energy kahan ja rahi hai? Kya kar rahi hai? [serious] Yeh energy particles ke beech ke forces ko todne mein use ho rahi hai. [enthusiasm] Samjho ke solid mein particles bilkul jaise cricket team ke players hain jo bohot tight formation mein khare hain, ek doosre ko pakre huwe. [soft] Inko alag karne ke liye, inke beech ke forces todne ke liye energy chahiye! Jab aap energy do, toh yeh forces toot jate hain aur particles free ho kar move kar sakte hain - liquid ya gas ban jata hai. [interest] Ab opposite dekho - jab freezing ya condensation hoti hai toh kya hota hai? [cheerful] Tab particles wapis paas aa rahe hote hain, forces ban rahe hote hain unke beech. [soft] Aur jab forces bante hain toh energy release hoti hai - yeh exothermic process hai. [short pause] Bilkul jaise do magnets ko paas lao toh woh khud aa kar jud jate hain aur thora heat feel hota hai. [serious] Isliye jab pani freeze hota hai ya steam condense hoti hai, toh energy release hoti hai surroundings mein. [interest] Yeh concept exam mein bohot aata hai! Yaad rakhna: melting aur evaporation endothermic hain - energy chahiye. Freezing aur condensation exothermic hain - energy release hoti hai.	media/lectures/3_2_slide_5.mp3	2026-04-22 17:57:41.033642
75	3.2	6	Latent Heat: Hidden Energy	["Latent heat is energy needed to change state without changing temperature", "During melting, temperature stays constant at melting point until all solid melts", "All supplied energy breaks intermolecular forces, not increasing kinetic energy", "Specific latent heat of fusion: energy to melt 1 kg at melting point"]	[enthusiasm] Ab hum ek bohot interesting concept parrhenge - latent heat! [interest] Latent ka matlab hota hai hidden, chhupi hui. Yeh energy chhupi hoti hai kyunke temperature nahi barhati! [serious] Jab aap kisi substance ko melt kar rahe ho, toh ek ajeeb cheez hoti hai. [short pause] Maan lo aap ice ko 0°C par heat kar rahe ho. Ice melt ho rahi hai aur pani ban raha hai. [soft] Lekin jab tak saari ice pani nahi ban jati, temperature 0°C par hi ruk jata hai! Aage nahi barhta! [enthusiasm] Yeh bohot important observation hai - heat de rahe ho lekin temperature nahi barh raha! [interest] Toh woh heat kahan ja rahi hai? Kya kar rahi hai? [cheerful] Woh saari energy intermolecular forces ko todne mein lag rahi hai - particles ke beech ke bonds ko break karne mein. [soft] Bilkul waise jaise agar aap kisi building ko demolish kar rahe ho toh saari energy walls todne mein lag rahi hai, building ko upar uthane mein nahi. [short pause] Particles ki kinetic energy nahi barh rahi, matlab temperature nahi barh raha, lekin potential energy barh rahi hai kyunke forces toot rahe hain. [serious] Is energy ko hum latent heat kehte hain - hidden heat jo temperature change nahi karti. [interest] Ab specific latent heat of fusion ek measurement hai. [soft] Yeh batata hai ke 1 kilogram substance ko uske melting point par completely melt karne ke liye kitni energy chahiye hogi, without temperature change. [enthusiasm] Har substance ke liye yeh value different hoti hai. Pani ke liye yeh 334,000 J/kg hai - matlab 1 kg ice ko 0°C par melt karne ke liye 334,000 joules chahiye! [serious] Exam mein agar latent heat ki definition poochhi jaye toh zaroor likhna: latent heat is the energy required to change the state of a substance without changing its temperature, used to overcome intermolecular forces.	media/lectures/3_2_slide_6.mp3	2026-04-22 17:57:41.033642
76	3.2	7	Using Melting and Boiling Points	["Melting point and boiling point are characteristic properties used to identify substances", "Pure substances have sharp, well-defined melting points", "Impure substances melt over a range of temperatures", "Testing melting point helps assess purity of a substance"]	[interest] Ab dekho, melting point aur boiling point sirf changes of state ke liye nahi hain - yeh bohot useful properties bhi hain! [enthusiasm] Har substance ka apna unique melting point aur boiling point hota hai, jaise har insaan ka apna fingerprint hota hai. [soft] Agar humein koi unknown substance mila aur hum uska melting point measure kar lein, toh hum yeh identify kar sakte hain ke woh substance kya hai. [cheerful] Jaise agar koi white powder hai aur uska melting point 801°C nikla, toh immediately pata chal jayega ke yeh sodium chloride - namak hai! [short pause] Yeh characteristic properties kaafi useful hain chemistry mein. [serious] Ab ek bohot important concept hai purity ke baare mein. [interest] Agar koi substance bilkul pure hai, completely pure, toh uska melting point bohot sharp aur well-defined hoga. [soft] Matlab woh exactly ek hi temperature par melt hoga - jaise pure ice exactly 0°C par pighlega. [enthusiasm] Lekin agar substance impure hai, usme kuch aur mix hai, toh yeh over a range of temperatures melt hoga. [cheerful] Bilkul jaise agar aap pure doodh ki jagah pani mila hua doodh lo, toh properties change ho jayengi! [short pause] Maan lo aap ne koi substance heat kiya aur woh 78°C se 85°C tak slowly melt ho raha hai - iska matlab hai ke yeh impure hai. Pure hota toh exactly 78°C par ya 85°C par melt hota, range mein nahi. [serious] Isliye laboratories mein melting point test karke purity check karte hain. [interest] Pharmaceutical industry mein medicines ki purity check karne ke liye yeh method use hota hai. [soft] Agar medicine pure nahi hai toh melting point range mein hoga, pure hai toh sharp hoga. [serious] Exam mein agar yeh question aaye ke pure aur impure substance ki melting point mein kya difference hai, toh clearly likhna: a pure substance has a sharp melting point at one specific temperature, while an impure substance melts over a range of temperatures.	media/lectures/3_2_slide_7.mp3	2026-04-22 17:57:41.033642
77	3.2	8	Effect of Impurities on State Changes	["Dissolved impurities lower the melting/freezing point of a substance", "Dissolved impurities raise the boiling point of a substance", "These are called freezing point depression and boiling point elevation", "Practical application: salt added to roads in winter prevents ice formation"]	[enthusiasm] Ab hum ek fascinating topic par aaye hain - impurities ka effect! [interest] Jab aap kisi substance mein impurities dissolve karte ho, toh uske melting point aur boiling point change ho jate hain. [serious] Yeh colligative properties kehlati hain - yeh sirf dissolved particles ki number par depend karti hain, unki identity par nahi. [short pause] Pehle freezing point depression ko samajhte hain. [soft] Jab aap pure pani mein kuch dissolve kar do - jaise namak, toh us pani ka freezing point kam ho jata hai. [cheerful] Pure pani 0°C par freeze hota hai, lekin namak wala pani shayad -2°C ya -3°C par freeze hoga! [enthusiasm] Yeh concept real life mein bohot use hota hai! Sardi wale countries mein jab roads par ice jam jati hai, toh log salt spread karte hain roads par. [interest] Yeh salt pani mein dissolve ho kar uska freezing point kam kar deta hai, toh ice nahi jamti easily. [soft] Yeh freezing point depression ka practical application hai! [short pause] Ab boiling point elevation dekho. [serious] Jab impurities dissolve hoti hain toh boiling point barh jata hai. Pure pani 100°C par boilta hai, lekin agar namak daal do toh shayad 101°C ya 102°C par boilega. [cheerful] Isliye jab aap ghar mein daal ya salan bana rahe ho, usme namak hai, masale hain, toh woh 100°C se zyada temperature par boil kar raha hota hai! [interest] Ab yeh colligative properties interesting isliye hain kyunke yeh particles ki number par depend karti hain, type par nahi. [soft] Matlab agar aap 10 particles namak ke daal do ya 10 particles cheeni ke, effect same hoga - kyunke 10 particles hain. [serious] Exam mein agar yeh poochha jaye ke impurities ka kya effect hai, toh dono likhna: impurities lower the melting/freezing point and raise the boiling point. Example bhi dena: salt on roads in winter.	media/lectures/3_2_slide_8.mp3	2026-04-22 17:57:41.033642
78	3.3	1	What is Diffusion?	["Net movement of particles from higher to lower concentration", "Occurs due to random particle motion, no energy needed", "Continues until particles are evenly distributed (dynamic equilibrium)", "At equilibrium, particles still move but no net movement"]	[enthusiasm] Assalam-o-alaikum bachon! Aaj hum bohat hi important topic shuru kar rahe hain jo chemistry aur biology dono mein kaam aata hai - Diffusion. [interest] Pehla point dekho: diffusion matlab particles ka aik concentration se doosri concentration ki taraf move karna, lekin sirf higher se lower ki taraf. [soft] Bilkul aise samajh lo jaise Eid pe tumhare ghar mein mithai ka dabba khula hai aik kamre mein - khushbu phailti hai zaada concentration wale area se kam concentration wale area ki taraf, pooore ghar mein. [short pause] Yeh movement tab tak hoti rehti hai jab tak har jagah equal concentration na ho jaye. [serious] Doosra point bilkul clear karna zaroori hai: yeh random motion ki wajah se hota hai aur isko koi energy nahi deni parti, yeh spontaneous process hai. [enthusiasm] Matlab particles khud ba khud move karte hain, tumhe kuch karna nahi parta! [soft] Teesra point kehta hai ke diffusion tab tak continue hoti hai jab tak particles evenly distribute na ho jayein - isko hum dynamic equilibrium kehte hain. [interest] Jaise tumhare paas aik glass mein pani hai aur usme aik drop of food color daalo - pehle woh concentrated hota hai aik jagah, phir poore pani mein phail jata hai equally. [short pause] Aur chautha point samajhna bohot zaroori hai exam ke liye: equilibrium pe bhi particles move kar rahe hote hain continuously, lekin ab net movement zero hai. [serious] Net movement ka matlab overall direction mein koi change nahi, sab balanced hai. [cheerful] Bilkul jaise cricket match mein jab score tie ho jaye - dono teams effort kar rahi hain lekin overall koi aage nahi ja raha. [soft] Examiner hamesha poochta hai ke equilibrium pe movement rukti hai ya nahi - yaad rakho, movement rukti nahi, sirf net movement zero ho jati hai. [enthusiasm] Yeh concept bilkul clear hona chahiye tumhare dimagh mein!	media/lectures/3_3_slide_1.mp3	2026-04-22 18:18:52.798352
79	3.3	2	Diffusion in Gases vs Liquids	["Diffusion occurs in both gases and liquids", "Much faster in gases than in liquids", "Gas particles move more rapidly with more space between them", "Liquid particles are closer together and move slower"]	[interest] Ab hum dekhte hain ke diffusion gases aur liquids mein kaise different hoti hai. [soft] Pehli baat toh yeh hai ke diffusion dono states of matter mein hoti hai - gases mein bhi aur liquids mein bhi. [enthusiasm] Lekin difference kya hai? Speed ka! Gases mein diffusion bohot zyada fast hoti hai compared to liquids. [short pause] Iska reason samajhte hain properly. [serious] Gas particles ke paas bohot zyada space hota hai aik doosre se, aur woh bohot tez speed se move karte hain randomly. [interest] Jaise tumne kabhi dekhा ho ke agar koi perfume spray kare room mein, toh thori der mein poore kamre mein smell aa jati hai - yeh gas diffusion hai jo bohot fast hai. [soft] Lekin agar tum liquid mein food color dalo bina hilaye, toh usko uniformly phailne mein bohot zyada time lagta hai. [cheerful] Bilkul aise samjho jaise bazaar mein bheed ho - agar kam log hain toh tum jaldi walk kar sakte ho (gases), lekin agar bohot zyada bheed hai toh tumhari speed slow ho jati hai (liquids). [short pause] Liquid particles aik doosre ke bohot qareeb hote hain, closely packed, isliye unko move karna mushkil hota hai. [enthusiasm] Yeh wajah hai ke gas diffusion fast hai aur liquid diffusion slow! [serious] Exam mein agar comparison poocha jaye, toh dono reasons zaroor likho: gas particles have more kinetic energy aur more space between them. [soft] Yeh simple point hai lekin marks ke liye bohot important hai, examiners specifically yeh reason dekhna chahte hain.	media/lectures/3_3_slide_2.mp3	2026-04-22 18:18:52.798352
80	3.3	3	Ammonia and Hydrogen Chloride Experiment	["Classic experiment: NH₃ and HCl gases from opposite tube ends", "White ring of ammonium chloride forms where gases meet", "Ring forms closer to HCl end, not in middle", "Shows ammonia (lighter) diffuses faster than HCl (heavier)"]	[enthusiasm] Bachon, ab hum aik famous experiment ke baare mein parh rahe hain jo O-Level mein bohot common hai! [interest] Yeh experiment ammonia gas aur hydrogen chloride gas ka hai. [soft] Setup yeh hai ke aik lamba glass tube lete hain, aur uske dono opposite ends pe simultaneously dono gases release karte hain - aik end pe ammonia (NH₃) aur doosre end pe hydrogen chloride (HCl). [short pause] Ab yeh dono gases diffuse karna shuru karti hain tube ke andar. [serious] Jab yeh dono gases tube mein milti hain, toh aik chemical reaction hoti hai aur white ring ban jati hai - yeh ring ammonium chloride (NH₄Cl) ki hoti hai jo solid hai. [interest] Ab interesting baat yeh hai ke yeh white ring tube ke beech mein nahi banti! [enthusiasm] Yeh ring hydrogen chloride wale end ke zyada qareeb banti hai. [soft] Iska matlab kya hua? Iska matlab yeh hai ke ammonia gas ne zyada distance cover kiya compared to HCl. [cheerful] Bilkul aise samjho jaise do log cycle race mein opposite directions se start karte hain ek sadak pe - jis ki speed zyada hogi woh zyada door ja kar milega doosre se. [short pause] Ammonia molecules lighter hote hain, unka molecular mass kam hai, isliye woh zyada fast diffuse karte hain. [serious] Hydrogen chloride molecules heavier hain, unka molecular mass zyada hai, toh woh slow diffuse karte hain. [interest] Yeh experiment Graham's law of diffusion ko demonstrate karta hai jo kehta hai ke lighter molecules diffuse faster. [soft] Exam mein agar yeh experiment poocha jaye toh teen cheezein zaroor mention karo: white ring kahan banti hai, ring kis cheez ki bani hai (NH₄Cl), aur kyun closer to HCl end banti hai. [enthusiasm] Yeh aik straightforward 4-5 marks ka question ban sakta hai paper mein!	media/lectures/3_3_slide_3.mp3	2026-04-22 18:18:52.798352
81	3.3	4	Factors Affecting Rate of Diffusion	["Temperature: Higher temperature means faster diffusion", "Molecular mass: Lighter molecules diffuse faster", "Concentration gradient: Steeper gradient means faster diffusion", "Viscosity (in liquids): Less viscous liquids allow faster diffusion"]	[serious] Ab hum samajhte hain ke diffusion ki speed kis kis cheez pe depend karti hai. [interest] Pehla factor hai temperature - yeh bohot important hai! [enthusiasm] Jab temperature barh jati hai toh particles ko zyada kinetic energy milti hai, aur woh zyada fast move karte hain. [soft] Bilkul jaise tumne garmi mein aur sardi mein perfume ka experiment karo - garmi mein smell bohot jaldi phailti hai kyunke molecules fast move kar rahe hote hain. [short pause] Thandi mein slow diffusion hoti hai kyunke particles ki movement slow hoti hai. [cheerful] Yeh bilkul waise hai jaise bijli ka pankha fast speed pe chalaye toh hawa jaldi phaile, slow speed pe toh kam phaile! [serious] Doosra factor molecular mass hai - lighter molecules zyada tez diffuse karte hain compared to heavier molecules at same temperature. [interest] Humne previous slide mein dekha ke ammonia lighter hai toh fast diffuse karta hai. [soft] Teesra factor concentration gradient hai - yeh means difference between higher aur lower concentration. [enthusiasm] Agar difference bohot zyada hai (steep gradient) toh diffusion bohot fast hogi, agar kam difference hai toh slow hogi. [short pause] Jaise agar tumhare paas chai ki tray hai aur tumhe saari chai siblings ko distribute karni hai - agar sab ke paas bilkul zero cups hain aur tumhare paas 10 cups hain toh tum jaldi distribute karoge, lekin agar sab ke paas already 5 cups hain aur tumhare paas 6 hain toh slow distribute hoga. [interest] Chautha factor sirf liquids ke liye hai - viscosity. [soft] Viscosity matlab liquid ki thickness, jaise honey bohot viscous hai aur pani kam viscous. [serious] Kam viscous liquids mein particles easily move kar sakte hain toh diffusion fast hoti hai. [cheerful] Jaise pani mein food color jaldi phaile compared to honey mein! [soft] Exam mein agar factors poochhe jayein toh in chaaron ko explain karo with proper reasoning - examiners reasoning dekhte hain sirf names nahi!	media/lectures/3_3_slide_4.mp3	2026-04-22 18:18:52.798352
82	3.3	5	Biological Importance of Diffusion	["Gas exchange in lungs: O₂ diffuses into blood, CO₂ out", "Nutrients diffuse from blood into body cells", "Waste products diffuse out of cells into blood", "CO₂ enters plant leaves through stomata for photosynthesis"]	[enthusiasm] Bachon, ab samajhte hain ke diffusion sirf theory nahi hai - yeh humare jism mein har waqt ho rahi hai! [interest] Sabse important example hai humari breathing system mein gas exchange. [soft] Jab tum saans lete ho toh oxygen air se tumhare lungs mein jati hai, aur phir lungs se blood mein diffuse hoti hai. [serious] Yeh diffusion isliye hoti hai kyunke oxygen ki concentration air mein zyada hai aur blood mein kam hai - toh oxygen naturally higher se lower concentration ki taraf move karti hai. [short pause] Same time pe carbon dioxide jo blood mein zyada concentration mein hai, woh lungs mein diffuse hoti hai aur phir tum exhale karte waqt bahar nikal jati hai. [interest] Yeh process har ek saans ke saath ho raha hai automatically! [cheerful] Bilkul jaise market mein goods distributor se dukaan tak pahunchte hain jahan demand hai - body mein bhi oxygen jahan chahiye wahan diffuse ho kar pahunchti hai. [soft] Doosri important process hai nutrients ka diffusion. [enthusiasm] Jab tum khana khate ho aur woh digest hota hai, toh nutrients blood mein absorb ho jate hain. [serious] Phir yeh nutrients blood se body cells ke andar diffuse hote hain through cell membranes, kyunke blood mein concentration zyada hai aur cells mein kam. [short pause] Ulta process bhi hota hai - cells mein jo waste products bante hain metabolism ki wajah se, woh cells se bahar blood mein diffuse hote hain taake body se remove ho sakein. [interest] Plants mein bhi diffusion bohot important hai! [soft] Jab plant photosynthesis karta hai toh use carbon dioxide chahiye hoti hai. [enthusiasm] Yeh CO₂ air se leaf ke andar diffuse hoti hai through chhote chhote pores jo stomata kehlate hain. [cheerful] Bilkul jaise tumhare ghar mein khidkiyaan hain ventilation ke liye - plants ki leaves mein stomata hain gas exchange ke liye! [serious] Exam mein agar biological importance poocha jaye toh specific examples dena - O₂ and CO₂ exchange in lungs, nutrient absorption, aur plant photosynthesis. [soft] Yeh teen examples zaroor yaad rakho kyunke paper mein common hain!	media/lectures/3_3_slide_5.mp3	2026-04-22 18:18:52.798352
83	3.3	6	Industrial and Medical Applications	["Kidney dialysis: waste products diffuse from blood through membrane", "Semi-permeable membrane allows selective diffusion", "Essential for patients with kidney failure", "Understanding diffusion fundamental to chemistry and biology"]	[serious] Bachon, diffusion sirf natural processes mein nahi, medical field mein bhi life-saving hoti hai. [interest] Sabse important example hai kidney dialysis. [soft] Samajhte hain yeh kya hai properly. [short pause] Humare kidneys ka kaam hai blood ko clean karna aur waste products ko remove karna. [serious] Lekin agar kisi patient ki kidneys kaam nahi kar rahi hain (kidney failure), toh unka blood clean nahi ho sakta naturally. [enthusiasm] Is problem ka solution hai dialysis machine! [interest] Is machine mein patient ka blood aik tube se nikalta hai aur aik special semi-permeable membrane se guzarta hai. [soft] Semi-permeable membrane ka matlab hai ke yeh sirf chhoti molecules ko pass karne deti hai, bari molecules nahi. [cheerful] Bilkul jaise channi hai jisse aap aata chaan te ho - chhote particles nikal jate hain aur bare reh jate hain. [serious] Blood mein jo waste products hain jaise urea aur extra salts, woh high concentration mein hote hain blood mein. [short pause] Membrane ke doosri taraf aik special dialysis fluid hoti hai jisme in waste products ki concentration bohot kam hoti hai ya bilkul nahi hoti. [enthusiasm] Toh diffusion automatically start ho jati hai - waste products blood se dialysis fluid mein diffuse ho jate hain! [interest] Yeh process patient ki jaan bacha leta hai kyunke blood clean ho jata hai. [soft] Thousands of patients Pakistan mein regular dialysis karwate hain kyunke unki kidneys kaam nahi karti. [serious] Yeh aik perfect medical application hai diffusion ka jo show karta hai ke chemistry sirf books mein nahi, real life mein kitni important hai. [enthusiasm] Isliye diffusion ko fundamental concept kaha jata hai chemistry aur biology dono subjects ke liye! [cheerful] Jab tum doctor ya scientist bano ge future mein, toh yeh concepts tumhare kaam aayenge. [soft] Exam mein agar applications poochhe jayein toh dialysis zaroor mention karo with proper explanation ke waste products kaise diffuse hote hain - yeh aik complete 3-4 marks ka answer ban sakta hai!	media/lectures/3_3_slide_6.mp3	2026-04-22 18:18:52.798352
\.


--
-- Data for Name: note_clips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.note_clips (id, user_id, topic_id, source, content, slide_number, created_at) FROM stdin;
1	5	1.4	english	equal sharing occurs when the two atoms have different electronegativities — one atom attracts the share	\N	2026-04-24 18:05:38.661849
3	5	1.1	english	The metal atom loses electrons to become a positively charged cation, while the non-metal gains these electrons to become a negatively charged anion.	\N	2026-04-24 18:32:48.695483
4	5	1.1	lecture	What is an Ionic Bond?\nIonic bond forms through electrostatic attraction between oppositely charged ions\nElectrons are transferred from one atom to another\nMetal atoms lose electrons (cation), non-metals gain electrons (anion)\nStrong electrostatic force holds ions together in ionic compounds	1	2026-04-24 18:52:28.002741
\.


--
-- Data for Name: notes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notes (id, user_id, topic_id, content, updated_at) FROM stdin;
1	5	1.1	<p><strong>This is the test of Notes Feature.</strong></p><ol><li><p>Test 1</p></li><li><p>Test 2</p></li></ol><p></p><p>"The metal atom loses electrons to become a positively charged cation, while the non-metal gains these electrons to become a negatively charged anion."</p><p></p><p></p><p><strong>Lecture Slide 1</strong></p><p>"What is an Ionic Bond? Ionic bond forms through electrostatic attraction between oppositely charged ions Electrons are transferred from one atom to another Metal atoms lose electrons (cation), non-metals gain electrons (anion) Strong electrostatic force holds ions together in ionic compounds"</p><p></p><p></p><p>Non-metals have high electron affinity and readily gain electrons<br><br><strong>Interesting Facts:</strong></p><p></p><p>Ionic compounds have high melting and boiling points due to strong electrostatic forces between ions. They do not conduct electricity in their solid state, but become conductive when dissolved in water or melted, allowing the ions to become mobile. The formation of ionic bonds typically occurs between metals and non-metals, resulting in a strong, rigid crystal lattice structure. Examples of ionic compounds include sodium chloride, magnesium oxide, and calcium chloride.<br><br><strong>Urdu:</strong><br><br>آئونی بانڈ ایک قسم کا کیمیائی بانڈ ہے جو مخالف طور پر چارج شدہ آئنز کے مابین الیکٹروسٹیٹک کشش کے ذریعے تشکیل پاتا ہے۔ یہ قسم کا بانڈنگ تب ہوتا ہے جب الیکٹرانوں کو ایک ایٹم سے دوسرے ایٹم میں منتقل کیا جاتا ہے، عام طور پر دھات سے غیر دھات تک۔ دھاتی ایٹم الیکٹران کھو دیتا ہے اور مثبت چارج والا کیشن بن جاتا ہے، جبکہ غیر دھاتی ایٹم ان الیکٹرانوں کو حاصل کرتا ہے اور منفی چارج والا انائن بن جاتا ہے۔ نتیجہ خیز الیکٹروسٹیٹک قوت ان مخالف چارج والے آئنز کے مابین انہیں آئونی مرکب میں ایک ساتھ رکھتی ہے۔</p>	2026-04-24 20:24:07.579245
\.


--
-- Data for Name: otp_verifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.otp_verifications (id, user_id, otp_code, purpose, expires_at, used, created_at) FROM stdin;
3	5	711126	email_verification	2026-04-17 09:39:51.739113	t	2026-04-17 14:29:51.740726
4	5	946543	password_reset	2026-04-18 03:58:04.400869	t	2026-04-18 08:48:04.403927
5	3	752882	password_reset	2026-04-18 04:29:07.752021	t	2026-04-18 09:19:07.755211
6	6	188400	email_verification	2026-04-19 14:01:25.678618	f	2026-04-19 18:51:25.68418
7	8	163413	email_verification	2026-04-24 12:39:15.708164	f	2026-04-24 17:29:15.549905
\.


--
-- Data for Name: question_performance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.question_performance (id, quiz_attempt_id, user_id, topic_id, question_type, question_text, student_answer, correct_answer, reference_answer, is_correct, similarity_score, points_earned, points_possible, answered_at) FROM stdin;
\.


--
-- Data for Name: quiz_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_attempts (id, user_id, topic_id, format_used, mcq_score, subjective_score, total_score, mcq_responses, subjective_responses, time_spent_learning_seconds, quiz_duration_seconds, attempted_at) FROM stdin;
1	5	1.1	english	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) High electronegativity", "B) Low ionization energy", "C) High electron affinity", "D) Noble gas configuration"], "question": "What is the primary reason why metals tend to lose electrons in ionic bonding?", "explanation": "Metals have low ionization energies, making it easier for them to lose electrons.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Low melting and boiling points", "B) High reactivity with water", "C) High melting and boiling points", "D) Low solubility in water"], "question": "Which of the following properties is a result of the strong electrostatic forces between ions in ionic compounds?", "explanation": "The strong electrostatic forces between ions in ionic compounds require significant energy to overcome, resulting in high melting and boiling points.", "correct_answer": "C"}, {"id": "mcq_3", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become more mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When an ionic compound is dissolved in water, the ions become mobile and can conduct electricity.", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) Lattice energy", "B) Ionization energy", "C) Electron affinity", "D) Electronegativity"], "question": "What is the term for the energy required to separate one mole of an ionic solid into gaseous ions?", "explanation": "Lattice energy is the energy required to separate one mole of an ionic solid into gaseous ions.", "correct_answer": "A"}, {"id": "mcq_5", "options": ["A) Sodium chloride (NaCl)", "B) Magnesium oxide (MgO)", "C) Calcium chloride (CaCl₂)", "D) Potassium iodide (KI)"], "question": "Which of the following ionic compounds would have the highest lattice energy?", "explanation": "Magnesium oxide (MgO) would have the highest lattice energy due to its smaller ions and higher charge.", "correct_answer": "B"}]}	{"answers": [{"id": "sub_1", "question": "Explain why ionic compounds do not conduct electricity in their solid state, but do conduct electricity when dissolved in water or melted.", "reference_answer": "In the solid state, the ions are fixed in position within the crystal lattice, preventing the flow of electric current. However, when dissolved in water or melted, the ions become mobile and can move freely, allowing them to conduct electricity."}, {"id": "sub_2", "question": "Describe the difference in electronegativity between metals and non-metals and how this difference contributes to the formation of ionic bonds.", "reference_answer": "Metals have low electronegativity, while non-metals have high electronegativity. This difference in electronegativity leads to the transfer of electrons from metals to non-metals, resulting in the formation of ionic bonds between the positively charged metal ions and negatively charged non-metal ions."}]}	\N	\N	2026-04-18 06:14:39.478387
2	5	1.1	english	60	3	32	{"answers": [{"id": "mcq_1", "options": ["A) High electronegativity", "B) Low ionization energy", "C) High electron affinity", "D) Noble gas configuration"], "question": "What is the main reason why metals like sodium readily lose their valence electrons to form cations?", "explanation": "Metals like sodium have low ionization energies, making it easy for them to lose their valence electrons.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) They are good conductors of electricity", "B) They have low melting and boiling points", "C) They do not conduct electricity", "D) They have a random arrangement of ions"], "question": "Which of the following is a characteristic of ionic compounds in their solid state?", "explanation": "Ionic compounds do not conduct electricity in their solid state because the ions are fixed in position.", "correct_answer": "C"}, {"id": "mcq_3", "options": ["A) Lattice energy", "B) Ionization energy", "C) Electron affinity", "D) Electronegativity"], "question": "What is the term for the energy required to separate one mole of an ionic solid into gaseous ions?", "explanation": "Lattice energy is the energy required to separate one mole of an ionic solid into gaseous ions.", "correct_answer": "A"}, {"id": "mcq_4", "options": ["A) Larger ions", "B) Lower charges", "C) Smaller ions and higher charges", "D) Higher electronegativity difference"], "question": "Which of the following factors would increase the lattice energy of an ionic compound?", "explanation": "Compounds with smaller ions and higher charges generally have greater lattice energies.", "correct_answer": "C"}, {"id": "mcq_5", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become more mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When an ionic compound is dissolved in water, the ions become mobile and can conduct electricity.", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Describe the process by which a metal atom and a non-metal atom form an ionic bond, including the resulting ions and their charges.", "reference_answer": "A metal atom loses one or more electrons to become a positively charged cation, while a non-metal atom gains one or more electrons to become a negatively charged anion. The resulting electrostatic force of attraction between the oppositely charged ions holds them together in an ionic compound."}, {"id": "sub_2", "question": "Explain why ionic compounds typically have high melting and boiling points, and provide an example of an ionic compound that exhibits this property.", "reference_answer": "Ionic compounds have high melting and boiling points due to the strong electrostatic forces between the ions, which require significant energy to overcome. For example, sodium chloride (NaCl) has a high melting point of 801°C and a high boiling point of 1413°C, making it a typical ionic compound with these properties."}]}	\N	\N	2026-04-18 06:14:39.478859
3	5	1.1	english	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) High electronegativity", "B) Low ionization energy", "C) High electron affinity", "D) Noble gas configuration"], "question": "What is the main reason why metals like sodium readily lose their valence electrons to form ions?", "explanation": "Metals have low ionization energies, making it easy for them to lose electrons", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Ionic compounds have lower melting points", "B) Ionic compounds have higher melting points due to weaker forces", "C) Ionic compounds have higher melting points due to strong electrostatic forces", "D) Ionic compounds have similar melting points"], "question": "How do the physical properties of ionic compounds compare to those of covalent compounds?", "explanation": "Ionic compounds have high melting points due to strong electrostatic forces between ions", "correct_answer": "C"}, {"id": "mcq_3", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become more mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When dissolved in water, the ions in an ionic compound become mobile and can conduct electricity", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) Lattice energy decreases as ionic bond strength increases", "B) Lattice energy increases as ionic bond strength decreases", "C) Lattice energy is unrelated to ionic bond strength", "D) Lattice energy increases as ionic bond strength increases"], "question": "What is the relationship between lattice energy and the strength of ionic bonds?", "explanation": "Lattice energy is a measure of the strength of ionic bonds, and higher lattice energies indicate stronger bonds", "correct_answer": "D"}, {"id": "mcq_5", "options": ["A) To minimize attractive forces between ions", "B) To maximize repulsive forces between ions", "C) To maximize attractive forces and minimize repulsive forces", "D) To randomize the arrangement of ions"], "question": "Why do ionic compounds typically have a regular, repeating crystal lattice structure?", "explanation": "The crystal lattice structure of ionic compounds maximizes attractive forces and minimizes repulsive forces between ions", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the difference in electronegativity between metals and non-metals contributes to the formation of ionic bonds", "reference_answer": "The difference in electronegativity between metals and non-metals leads to the transfer of electrons from the metal to the non-metal, resulting in the formation of ions with opposite charges, which are then attracted to each other to form an ionic bond"}, {"id": "sub_2", "question": "Describe the cause-and-effect relationship between the mobility of ions in an ionic compound and its ability to conduct electricity", "reference_answer": "When the ions in an ionic compound are mobile, such as when the compound is dissolved in water or melted, they are able to move and carry electrical charge, allowing the compound to conduct electricity. In contrast, when the ions are fixed in position, as in a solid ionic compound, they are unable to move and carry charge, resulting in the compound being unable to conduct electricity"}]}	\N	\N	2026-04-18 06:15:23.617966
4	5	1.1	english	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) Low ionization energies of metal atoms", "B) High electronegativity of non-metal atoms", "C) Strong electrostatic forces between ions", "D) Weak intermolecular forces between molecules"], "question": "What is the primary reason for the high melting points of ionic compounds?", "explanation": "The strong electrostatic forces between ions require significant energy to overcome, resulting in high melting points.", "correct_answer": "C"}, {"id": "mcq_2", "options": ["A) They conduct electricity in solid state but not in dissolved or molten state", "B) They have high melting points in solid state but low boiling points in dissolved or molten state", "C) They are insoluble in water in solid state but soluble in dissolved or molten state", "D) They do not conduct electricity in solid state but conduct electricity in dissolved or molten state"], "question": "How do the physical properties of ionic compounds in their solid state differ from those in their dissolved or molten state?", "explanation": "In their solid state, ionic compounds do not conduct electricity because the ions are fixed in position, but when dissolved or melted, the ions become mobile and can conduct electricity.", "correct_answer": "D"}, {"id": "mcq_3", "options": ["A) Larger ions result in higher lattice energy", "B) Smaller ions result in lower lattice energy", "C) Larger ions result in lower lattice energy", "D) Smaller ions result in higher lattice energy"], "question": "What is the relationship between lattice energy and the size of ions in an ionic compound?", "explanation": "Compounds with smaller ions generally have greater lattice energies due to the stronger electrostatic forces between the ions.", "correct_answer": "D"}, {"id": "mcq_4", "options": ["A) To achieve a noble gas configuration", "B) To increase their electronegativity", "C) To decrease their ionization energy", "D) To achieve a stable electron configuration"], "question": "Why do metal atoms tend to lose electrons to form cations?", "explanation": "Metal atoms tend to lose electrons to achieve a stable electron configuration, which is often a noble gas configuration.", "correct_answer": "D"}, {"id": "mcq_5", "options": ["A) It determines the size of the ions", "B) It determines the charge of the ions", "C) It determines the direction of electron transfer between atoms", "D) It determines the reactivity of the atoms"], "question": "What is the role of electronegativity in the formation of ionic bonds?", "explanation": "The difference in electronegativity between metal and non-metal atoms determines the direction of electron transfer, with electrons being transferred from the metal to the non-metal.", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Compare and contrast the properties of ionic compounds with those of covalent compounds, using examples to support your answer.", "reference_answer": "Ionic compounds have high melting points, are typically hard and brittle, and conduct electricity when dissolved or melted, whereas covalent compounds have lower melting points, are often softer and more flexible, and do not conduct electricity. For example, sodium chloride is an ionic compound with a high melting point, while methane is a covalent compound with a low melting point."}, {"id": "sub_2", "question": "Describe a real-world application of ionic compounds, explaining how their unique properties make them useful in this context.", "reference_answer": "One real-world application of ionic compounds is in the production of table salt, which is an ionic compound composed of sodium and chlorine ions. The high melting point and solubility of table salt make it useful as a seasoning and preservative in food, while its ionic nature allows it to conduct electricity when dissolved, which is useful in various industrial applications."}]}	\N	\N	2026-04-18 06:15:23.618998
5	5	1.2	visual	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) Covalent bonds involve the transfer of electrons, while ionic bonds involve sharing", "B) Ionic bonds involve the transfer of electrons, while covalent bonds involve sharing", "C) Both types of bonds involve the transfer of electrons", "D) Both types of bonds involve the sharing of electrons"], "question": "What is the main difference between ionic and covalent bonds in terms of electron transfer?", "explanation": "In ionic bonds, electrons are transferred from one atom to another, while in covalent bonds, electrons are shared between atoms.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Methane", "B) Carbon dioxide", "C) Both have the same melting point", "D) It depends on the pressure"], "question": "Which of the following covalent compounds is likely to have a higher melting point, methane or carbon dioxide?", "explanation": "As a general trend, covalent compounds with stronger intermolecular forces tend to have higher melting points. Carbon dioxide has stronger intermolecular forces due to its larger molecular weight and polarity.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) Molecular geometry", "B) Intermolecular forces", "C) Electron configuration", "D) Valence shell"], "question": "What is the term for the arrangement of atoms in a molecule that affects its physical and chemical properties?", "explanation": "The arrangement of atoms in a molecule is referred to as its molecular geometry, which influences the molecule's physical and chemical properties.", "correct_answer": "A"}, {"id": "mcq_4", "options": ["A) They form ions in water", "B) They have a low melting point", "C) They do not form ions in water", "D) They are all gases"], "question": "Why do covalent compounds generally not conduct electricity, even when dissolved in water?", "explanation": "Covalent compounds do not conduct electricity because they do not form ions when dissolved in water, unlike ionic compounds.", "correct_answer": "C"}, {"id": "mcq_5", "options": ["A) Single covalent bond", "B) Double covalent bond", "C) Triple covalent bond", "D) Ionic bond"], "question": "What type of bond is formed when two atoms share three pairs of electrons?", "explanation": "A triple covalent bond involves the sharing of three pairs of electrons between two atoms, resulting in a strong and short bond.", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the molecular geometry of a covalent compound can affect its reactivity. Provide an example to support your answer.", "reference_answer": "The molecular geometry of a covalent compound can affect its reactivity by influencing the accessibility of the molecule's active sites. For example, the bent shape of water molecules allows them to form hydrogen bonds with other molecules, which is important for its reactivity in many chemical reactions."}, {"id": "sub_2", "question": "Discuss the relationship between the number of shared electron pairs in a covalent bond and the bond's strength. How does this relationship affect the physical properties of covalent compounds?", "reference_answer": "As the number of shared electron pairs in a covalent bond increases, the bond becomes stronger and shorter. This relationship affects the physical properties of covalent compounds, such as their melting and boiling points, with stronger bonds resulting in higher melting and boiling points."}]}	\N	\N	2026-04-18 09:20:30.510209
6	5	1.2	visual	100	87	94	{"answers": [{"id": "mcq_1", "options": ["A) Electrons are shared in ionic bonds but transferred in covalent bonds", "B) Electrons are transferred in ionic bonds but shared in covalent bonds", "C) Electrons are always transferred in both types of bonds", "D) Electrons are never shared in either type of bond"], "question": "What is the main difference between the way electrons are involved in ionic and covalent bonds?", "explanation": "In ionic bonds, electrons are transferred from one atom to another, while in covalent bonds, electrons are shared between atoms.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Covalent compounds have higher melting and boiling points", "B) Covalent compounds have lower melting and boiling points", "C) The melting and boiling points are the same for both types of compounds", "D) It depends on the specific compounds being compared"], "question": "How do the properties of covalent compounds compare to those of ionic compounds in terms of melting and boiling points?", "explanation": "Covalent compounds typically have lower melting and boiling points than ionic compounds because the intermolecular forces between covalent molecules are weaker.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) As the number of shared electron pairs increases, the bond becomes weaker", "B) As the number of shared electron pairs increases, the bond becomes stronger", "C) The number of shared electron pairs has no effect on the strength of the bond", "D) The relationship between shared electron pairs and bond strength is unpredictable"], "question": "What is the relationship between the number of shared electron pairs in a covalent bond and the strength of the bond?", "explanation": "As the number of shared electron pairs increases, the bond becomes shorter and stronger, requiring more energy to break.", "correct_answer": "B"}, {"id": "mcq_4", "options": ["A) Because they are very reactive", "B) Because they are very stable", "C) Because they do not form ions", "D) Because they are always insoluble in water"], "question": "Why do most covalent compounds not conduct electricity, even when dissolved in water?", "explanation": "Most covalent compounds do not conduct electricity because they do not form ions when dissolved in water.", "correct_answer": "C"}, {"id": "mcq_5", "options": ["A) To show the arrangement of electrons in an atom", "B) To predict the shape of a molecule and understand its chemical behavior", "C) To identify the type of bond between two atoms", "D) To determine the molecular weight of a compound"], "question": "What is the purpose of using Lewis structures to represent covalent bonding?", "explanation": "Lewis structures are used to represent covalent bonding and help predict molecular shapes and understand chemical behavior.", "correct_answer": "B"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the molecular geometry of a covalent compound, such as water, contributes to its unique properties. Provide an example of one of these properties.", "reference_answer": "The molecular geometry of water, which is bent, contributes to its unique properties. For example, the bent shape of water molecules allows them to form hydrogen bonds with each other, which gives water its high surface tension and boiling point."}, {"id": "sub_2", "question": "Compare and contrast the solubility of covalent compounds in polar and non-polar solvents. Use the example of methane to support your answer.", "reference_answer": "Covalent compounds are generally more soluble in non-polar solvents than in polar solvents. For example, methane is soluble in non-polar solvents like hexane but insoluble in water, which is a polar solvent. This is because non-polar solvents do not have a charge, allowing them to interact with non-polar covalent compounds like methane through weak intermolecular forces."}]}	\N	\N	2026-04-18 09:20:30.512017
7	5	1.2	visual	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) Hydrogen gas has a double bond and oxygen gas has a single bond", "B) Hydrogen gas has a single bond and oxygen gas has a double bond", "C) Hydrogen gas has a triple bond and oxygen gas has a single bond", "D) Hydrogen gas has no bonds and oxygen gas has a double bond"], "question": "What is the main difference between the bonding in hydrogen gas and oxygen gas?", "explanation": "Hydrogen gas has a single covalent bond, while oxygen gas has a double covalent bond.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Ammonia", "B) Methane", "C) Carbon dioxide", "D) Water"], "question": "Which of the following covalent compounds is most likely to be insoluble in water?", "explanation": "Methane is a non-polar covalent compound and is insoluble in water.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) Electrostatic attraction", "B) Molecular geometry", "C) Intermolecular forces", "D) Valence electrons"], "question": "What is the term for the arrangement of atoms in a molecule that affects its physical and chemical properties?", "explanation": "Molecular geometry refers to the arrangement of atoms in a molecule, which affects its properties.", "correct_answer": "B"}, {"id": "mcq_4", "options": ["A) The bond becomes weaker as the number of shared pairs increases", "B) The bond becomes stronger as the number of shared pairs increases", "C) The bond's strength is unaffected by the number of shared pairs", "D) The bond's strength decreases then increases with the number of shared pairs"], "question": "How does the number of shared electron pairs in a covalent bond affect the bond's strength?", "explanation": "As the number of shared electron pairs increases, the covalent bond becomes stronger.", "correct_answer": "B"}, {"id": "mcq_5", "options": ["A) Ionic lattice diagram", "B) Electron configuration diagram", "C) Lewis structure", "D) Phase diagram"], "question": "What type of diagram is often used to represent covalent bonding and predict molecular shapes?", "explanation": "Lewis structures are used to represent covalent bonding and predict molecular shapes.", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the molecular geometry of water contributes to its unique properties, providing at least two examples.", "reference_answer": "The bent shape of water molecules allows for hydrogen bonding, which contributes to its high boiling point and surface tension. For example, water's unique shape allows it to dissolve a wide range of substances, and its high surface tension enables it to resist external forces."}, {"id": "sub_2", "question": "Compare and contrast the properties of covalent compounds with those of ionic compounds, focusing on their melting and boiling points, solubility, and ability to conduct electricity.", "reference_answer": "Covalent compounds have lower melting and boiling points, are less likely to conduct electricity, and are often soluble in non-polar solvents, whereas ionic compounds have higher melting and boiling points, can conduct electricity when dissolved in water, and are often soluble in water."}]}	\N	\N	2026-04-18 09:22:13.502087
8	5	1.2	visual	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) Weaker intermolecular forces between molecules", "B) Stronger covalent bonds between atoms", "C) Higher electronegativities of non-metal atoms", "D) Greater solubility in water"], "question": "What is the main reason why covalent compounds typically have lower melting and boiling points compared to ionic compounds?", "explanation": "Covalent compounds have weaker intermolecular forces between molecules, which results in lower melting and boiling points.", "correct_answer": "A"}, {"id": "mcq_2", "options": ["A) The bond becomes weaker and longer as the number of shared electron pairs increases", "B) The bond becomes stronger and shorter as the number of shared electron pairs increases", "C) The bond remains the same regardless of the number of shared electron pairs", "D) The bond becomes weaker and shorter as the number of shared electron pairs increases"], "question": "How does the number of shared electron pairs in a covalent bond affect the bond strength?", "explanation": "As the number of shared electron pairs increases, the bond becomes stronger and shorter, requiring more energy to break.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) The shape of a molecule has no effect on its physical and chemical properties", "B) The shape of a molecule affects only its physical properties", "C) The shape of a molecule affects only its chemical properties", "D) The shape of a molecule affects both its physical and chemical properties"], "question": "What is the relationship between the shape of a molecule and its physical and chemical properties?", "explanation": "The arrangement of atoms in a molecule affects its physical and chemical properties, such as the bent shape of water molecules contributing to water's unique properties.", "correct_answer": "D"}, {"id": "mcq_4", "options": ["A) They form ions in water", "B) They have high electronegativities", "C) They do not form ions in water", "D) They have strong intermolecular forces"], "question": "Why do most covalent compounds not conduct electricity, even when dissolved in water?", "explanation": "Most covalent compounds do not conduct electricity because they do not form ions, even when dissolved in water.", "correct_answer": "C"}, {"id": "mcq_5", "options": ["A) Polar solvents only", "B) Non-polar solvents only", "C) Both polar and non-polar solvents", "D) Water only"], "question": "What type of solvents are many covalent compounds typically soluble in?", "explanation": "Many covalent compounds are soluble in non-polar solvents but insoluble in water.", "correct_answer": "B"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the concept of molecular geometry is important in understanding the properties of covalent compounds, using the example of water molecules.", "reference_answer": "The molecular geometry of water molecules, which is bent, contributes to its unique properties. The bent shape allows for hydrogen bonding between molecules, which affects its physical and chemical properties, such as its high boiling point and solubility in many substances."}, {"id": "sub_2", "question": "Compare and contrast the properties of covalent compounds with those of ionic compounds, including their melting and boiling points, solubility, and ability to conduct electricity.", "reference_answer": "Covalent compounds have lower melting and boiling points, are less soluble in water, and do not conduct electricity, whereas ionic compounds have higher melting and boiling points, are more soluble in water, and can conduct electricity when dissolved in water. This is due to the weaker intermolecular forces and lack of ion formation in covalent compounds, compared to the stronger ionic bonds in ionic compounds."}]}	\N	\N	2026-04-18 09:22:13.502311
9	5	1.1	lecture	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) High electronegativity", "B) Low ionization energy", "C) High electron affinity", "D) Noble gas configuration"], "question": "What is the main reason why metals tend to lose electrons in ionic bonding?", "explanation": "Metals have low ionization energies, making it easy for them to lose electrons.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) They conduct electricity", "B) They have low melting points", "C) They have high boiling points", "D) They do not conduct electricity"], "question": "Which of the following is a characteristic of ionic compounds in their solid state?", "explanation": "In their solid state, ionic compounds do not conduct electricity because the ions are fixed in position.", "correct_answer": "D"}, {"id": "mcq_3", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become more mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When dissolved in water, the ions in an ionic compound become mobile and can conduct electricity.", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) Lattice energy", "B) Ionization energy", "C) Electron affinity", "D) Electronegativity"], "question": "What is the term for the energy required to separate one mole of an ionic solid into gaseous ions?", "explanation": "The lattice energy is the energy required to separate one mole of an ionic solid into gaseous ions.", "correct_answer": "A"}, {"id": "mcq_5", "options": ["A) Sodium chloride (NaCl)", "B) Magnesium oxide (MgO)", "C) Calcium chloride (CaCl2)", "D) Sodium oxide (Na2O)"], "question": "Which of the following ionic compounds would likely have the highest melting point?", "explanation": "Compounds with smaller ions and higher charges generally have greater lattice energies and higher melting points. Magnesium oxide has a smaller ion and a higher charge than the other options.", "correct_answer": "B"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the difference in electronegativity between metals and non-metals leads to the formation of ionic bonds.", "reference_answer": "The difference in electronegativity between metals and non-metals leads to the transfer of electrons from the metal to the non-metal, resulting in the formation of oppositely charged ions that are attracted to each other, forming an ionic bond."}, {"id": "sub_2", "question": "Describe the arrangement of ions in an ionic compound and how it relates to the strength of the ionic bonds.", "reference_answer": "The ions in an ionic compound arrange themselves in a regular, repeating three-dimensional pattern to maximize attractive forces and minimize repulsive forces. This arrangement creates a strong, rigid structure, with the strength of the ionic bonds depending on the lattice energy, which is influenced by the size of the ions and their charge."}]}	\N	\N	2026-04-23 19:46:27.747674
10	5	1.1	lecture	40	0	20	{"answers": [{"id": "mcq_1", "options": ["A) The transfer of electrons between atoms", "B) The sharing of electrons between atoms", "C) The repulsion of electrons between atoms", "D) The attraction of electrons between atoms"], "question": "What is the main difference between the formation of ionic bonds and other types of chemical bonds?", "explanation": "Ionic bonds are formed through the transfer of electrons from one atom to another, typically from a metal to a non-metal.", "correct_answer": "A"}, {"id": "mcq_2", "options": ["A) Sodium chloride (NaCl)", "B) Magnesium oxide (MgO)", "C) Calcium chloride (CaCl₂)", "D) Potassium fluoride (KF)"], "question": "Which of the following ionic compounds would have the highest melting point?", "explanation": "Magnesium oxide has a higher lattice energy due to its smaller ions and higher charges, resulting in a higher melting point.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When an ionic compound is dissolved in water, the ions become mobile and can conduct electricity.", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) High melting and boiling points", "B) Conductivity in solid state", "C) Formation through the transfer of electrons", "D) Regular crystal lattice structure"], "question": "Which of the following is NOT a characteristic of ionic compounds?", "explanation": "Ionic compounds do not conduct electricity in their solid state, but they can conduct electricity when dissolved in water or melted.", "correct_answer": "B"}, {"id": "mcq_5", "options": ["A) Lattice energy", "B) Ionization energy", "C) Electron affinity", "D) Electronegativity"], "question": "What is the term used to describe the energy required to separate one mole of an ionic solid into gaseous ions?", "explanation": "Lattice energy is the energy required to separate one mole of an ionic solid into gaseous ions.", "correct_answer": "A"}]}	{"answers": [{"id": "sub_1", "question": "Compare and contrast the properties of ionic compounds with those of covalent compounds. How do their bonding mechanisms affect their physical and chemical properties?", "reference_answer": "Ionic compounds have high melting and boiling points, are brittle, and conduct electricity when dissolved in water or melted. Covalent compounds have lower melting and boiling points, are more flexible, and do not conduct electricity. The bonding mechanisms of ionic compounds involve the transfer of electrons, resulting in the formation of ions with opposite charges, while covalent compounds involve the sharing of electrons between atoms."}, {"id": "sub_2", "question": "Describe a real-world example of an ionic compound and its practical applications. How does its ionic bonding contribute to its usefulness in this context?", "reference_answer": "Sodium chloride (NaCl) is a common ionic compound used as a seasoning and preservative in food. Its ionic bonding contributes to its high melting point and solubility in water, making it useful for preserving food and adding flavor. Additionally, its ionic nature allows it to conduct electricity when dissolved in water, which is useful in various industrial applications."}]}	\N	\N	2026-04-23 19:46:27.860398
11	5	1.1	urdu	0	0	0	{"answers": [{"id": "mcq_1", "options": ["A) Similar electronegativity values", "B) Difference in electronegativity", "C) Similar electron affinities", "D) Similar ionization energies"], "question": "What is the primary reason for the formation of ionic bonds between metals and non-metals?", "explanation": "The difference in electronegativity between metals and non-metals leads to the transfer of electrons and the formation of ionic bonds.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) Sodium chloride (NaCl)", "B) Magnesium oxide (MgO)", "C) Calcium chloride (CaCl₂)", "D) Potassium bromide (KBr)"], "question": "Which of the following ionic compounds would have the highest lattice energy?", "explanation": "Compounds with smaller ions and higher charges generally have greater lattice energies, and magnesium oxide has a smaller ion and a higher charge than the other options.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) They become less mobile", "B) They remain fixed in position", "C) They become more mobile and can conduct electricity", "D) They lose their charge"], "question": "What happens to the ions in an ionic compound when it is dissolved in water?", "explanation": "When an ionic compound is dissolved in water, the ions become mobile and can conduct electricity.", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) Due to the weak electrostatic forces between ions", "B) Due to the strong electrostatic forces between ions", "C) Due to the low ionization energies of the ions", "D) Due to the high electron affinities of the ions"], "question": "Why do ionic compounds typically have high melting and boiling points?", "explanation": "The strong electrostatic forces between ions in an ionic compound require significant energy to overcome, resulting in high melting and boiling points.", "correct_answer": "B"}, {"id": "mcq_5", "options": ["A) Ionization energy", "B) Electron affinity", "C) Lattice energy", "D) Electrostatic energy"], "question": "What is the term for the energy required to separate one mole of an ionic solid into gaseous ions?", "explanation": "Lattice energy is the energy required to separate one mole of an ionic solid into gaseous ions.", "correct_answer": "C"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the difference in electronegativity between metals and non-metals leads to the formation of ionic bonds. Use the example of sodium and chlorine to illustrate your answer.", "reference_answer": "The difference in electronegativity between metals and non-metals leads to the transfer of electrons from the metal to the non-metal, resulting in the formation of a positively charged cation and a negatively charged anion. In the case of sodium and chlorine, sodium loses one electron to become Na⁺, while chlorine gains one electron to become Cl⁻, resulting in the formation of an ionic bond between the two ions."}, {"id": "sub_2", "question": "Compare and contrast the properties of ionic compounds in their solid and dissolved states. How do the physical and chemical properties of ionic compounds change when they are dissolved in water?", "reference_answer": "In their solid state, ionic compounds have high melting and boiling points, and do not conduct electricity due to the fixed position of the ions in the crystal lattice. However, when dissolved in water, the ions become mobile and can conduct electricity. The physical and chemical properties of ionic compounds change significantly when they are dissolved in water, as the ions are able to move freely and interact with the surrounding water molecules."}]}	\N	\N	2026-04-24 20:37:00.408847
12	5	1.1	urdu	40	1	20	{"answers": [{"id": "mcq_1", "options": ["A) Similar electronegativity values", "B) Difference in electronegativity values", "C) Similar electron affinity values", "D) Similar ionization energy values"], "question": "What is the primary reason why metals and non-metals form ionic bonds?", "explanation": "The difference in electronegativity values between metals and non-metals leads to the transfer of electrons and the formation of ionic bonds.", "correct_answer": "B"}, {"id": "mcq_2", "options": ["A) They become less conductive", "B) They become more conductive", "C) They remain the same", "D) They become non-conductive"], "question": "How do the electrical conductivity properties of ionic compounds change when they are dissolved in water?", "explanation": "When ionic compounds are dissolved in water, the ions become mobile and can conduct electricity.", "correct_answer": "B"}, {"id": "mcq_3", "options": ["A) High lattice energy indicates weak ionic bonds", "B) Low lattice energy indicates weak ionic bonds", "C) High lattice energy indicates strong ionic bonds", "D) Lattice energy is not related to ionic bond strength"], "question": "What is the relationship between lattice energy and the strength of ionic bonds in a compound?", "explanation": "Compounds with higher lattice energies have stronger ionic bonds, which is a measure of the energy required to separate the ions.", "correct_answer": "C"}, {"id": "mcq_4", "options": ["A) Due to the weak electrostatic forces between ions", "B) Due to the strong electrostatic forces between ions", "C) Due to the low ionization energies of the metal atoms", "D) Due to the high electron affinities of the non-metal atoms"], "question": "Why do ionic compounds typically have high melting and boiling points?", "explanation": "The strong electrostatic forces between ions in ionic compounds require significant energy to overcome, resulting in high melting and boiling points.", "correct_answer": "B"}, {"id": "mcq_5", "options": ["A) The metal atom becomes a negatively charged anion and the non-metal atom becomes a positively charged cation", "B) The metal atom becomes a positively charged cation and the non-metal atom becomes a negatively charged anion", "C) Both atoms become neutral", "D) Both atoms become positively charged"], "question": "What is the result of the transfer of electrons from a metal atom to a non-metal atom in the formation of an ionic bond?", "explanation": "The transfer of electrons from a metal atom to a non-metal atom results in the formation of a positively charged cation and a negatively charged anion.", "correct_answer": "B"}]}	{"answers": [{"id": "sub_1", "question": "Explain how the difference in electronegativity between metals and non-metals leads to the formation of ionic bonds. Use the example of sodium and chlorine to illustrate your answer.", "reference_answer": "The difference in electronegativity between metals and non-metals leads to the transfer of electrons from the metal to the non-metal, resulting in the formation of a positively charged cation and a negatively charged anion. In the case of sodium and chlorine, sodium has a low electronegativity value and readily loses an electron to become a positively charged sodium ion, while chlorine has a high electronegativity value and readily gains an electron to become a negatively charged chloride ion."}, {"id": "sub_2", "question": "Compare and contrast the physical properties of ionic compounds in their solid and dissolved states. How do the arrangements of ions in these states affect their ability to conduct electricity?", "reference_answer": "In their solid state, ionic compounds have a rigid crystal lattice structure, where the ions are fixed in position and cannot move freely. As a result, they do not conduct electricity. However, when dissolved in water, the ions become mobile and can move freely, allowing them to conduct electricity. The arrangement of ions in the solid state is regular and repeating, which maximizes attractive forces and minimizes repulsive forces, resulting in a strong and rigid structure."}]}	\N	\N	2026-04-24 20:37:00.40869
\.


--
-- Data for Name: student_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_progress (user_id, topic_id, status, best_score, attempts_count, time_spent_seconds, last_accessed, completed_at) FROM stdin;
5	2.1	in_progress	\N	0	0	2026-04-17 14:32:51.078964	\N
5	1.6	in_progress	\N	0	0	2026-04-17 15:21:03.779604	\N
5	2.2	in_progress	\N	0	0	2026-04-17 15:21:42.307117	\N
3	1.1	in_progress	\N	0	0	2026-04-17 15:22:26.469852	\N
3	1.2	in_progress	\N	0	0	2026-04-17 18:24:48.89816	\N
5	5.2	in_progress	\N	0	0	2026-04-18 06:17:02.25703	\N
3	1.5	in_progress	\N	0	0	2026-04-18 07:32:15.625825	\N
3	1.4	in_progress	\N	0	0	2026-04-18 08:02:28.319215	\N
3	1.3	in_progress	\N	0	0	2026-04-18 08:13:31.140301	\N
3	4.5	in_progress	\N	0	0	2026-04-18 08:17:55.175504	\N
5	4.5	in_progress	\N	0	0	2026-04-18 08:34:06.804694	\N
5	3.1	in_progress	\N	0	0	2026-04-18 08:53:04.831224	\N
5	3.3	in_progress	\N	0	0	2026-04-18 08:53:14.979081	\N
3	1.6	in_progress	\N	0	0	2026-04-18 09:04:39.501432	\N
5	1.2	completed	94	1	0	2026-04-18 09:20:18.53167	\N
3	2.1	in_progress	\N	0	0	2026-04-19 06:16:16.491506	\N
5	4.6	in_progress	\N	0	0	2026-04-19 06:31:08.605764	\N
5	1.3	in_progress	\N	0	0	2026-04-19 12:39:59.139478	\N
5	1.4	in_progress	\N	0	0	2026-04-19 14:09:44.114996	\N
5	1.5	in_progress	\N	0	0	2026-04-19 15:13:44.463304	\N
3	2.3	in_progress	\N	0	0	2026-04-19 18:17:08.216848	\N
3	3.1	in_progress	\N	0	0	2026-04-22 16:42:54.366101	\N
5	2.3	in_progress	\N	0	0	2026-04-22 17:21:45.912104	\N
3	3.2	in_progress	\N	0	0	2026-04-22 17:49:08.407683	\N
5	3.2	in_progress	\N	0	0	2026-04-22 18:04:29.354772	\N
3	3.3	in_progress	\N	0	0	2026-04-22 18:13:12.901285	\N
3	2.4	in_progress	\N	0	0	2026-04-23 20:05:23.698746	\N
3	4.3	in_progress	\N	0	0	2026-04-23 20:06:42.756746	\N
3	4.6	in_progress	\N	0	0	2026-04-23 20:22:11.057599	\N
5	1.1	in_progress	32	3	0	2026-04-18 06:14:37.038145	\N
\.


--
-- Data for Name: student_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_questions (id, user_id, topic_id, question_text, answer_text, citation, was_helpful, asked_at) FROM stdin;
1	5	\N	What are bases?	The textbook content does not explicitly define or mention "bases" in the provided text. It does mention adenine and guanine as base pairs in DNA, but it does not provide a general definition of bases.	Chapter 1, Topic 1.5, Paragraph 3, Chapter 1, Topic 1.2, Paragraph 4, Chapter 1, Topic 1.5, Paragraph 2	\N	2026-04-18 06:16:46.170761
2	5	5.2	What are alkalis?	The textbook content does not mention "alkalis". The provided content only discusses ionic bonds, ionic compounds, and their properties, but does not define or mention alkalis.	Chapter 1, Topic 1.1, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 3, Chapter 1, Topic 1.1, Paragraph 1	\N	2026-04-18 06:17:23.336256
3	5	4.5	What is Electrolysis?	The textbook content does not mention electrolysis.	Chapter 1, Topic 1.4, Paragraph 1, Chapter 1, Topic 1.1, Paragraph 1, Chapter 1, Topic 1.5, Paragraph 1	\N	2026-04-18 08:35:37.852641
4	5	3.3	What is Diffusion?	The concept of diffusion is not mentioned in the provided textbook content.	Chapter 1, Topic 1.3, Paragraph 3, Chapter 1, Topic 1.3, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 1	\N	2026-04-18 08:53:48.686558
5	5	4.5	What is Electrolysis?	Electrolysis is the process of decomposing an ionic compound by passing an electric current through it when it is either molten or dissolved in water. The compound being electrolyzed is called the electrolyte, and it must contain mobile ions that can carry the electric current. This process involves the migration of ions towards oppositely charged electrodes, resulting in a non-spontaneous redox reaction. It is used to extract or purify metals, and has various industrial applications.	Chapter 1, Topic 4.5, Paragraph 4, Chapter 1, Topic 4.4, Paragraph 4, Chapter 1, Topic 4.5, Paragraph 1	\N	2026-04-18 09:00:18.824446
6	5	4.5	What is the main concept?	The main concept appears to be the explanation of various chemistry principles, including the kinetic particle theory, molecular geometry, Le Chatelier's Principle, and understanding proton and nucleon numbers. These concepts are fundamental to understanding the properties and behavior of matter, chemical reactions, and nuclear reactions. The textbook content covers a range of topics in chemistry, highlighting key theories and principles. Overall, the main concept is an introduction to essential chemistry principles.	Chapter 1, Topic 4.6, Paragraph 2, Chapter 1, Topic 1.2, Paragraph 4, Chapter 1, Topic 3.1, Paragraph 4	\N	2026-04-18 09:00:32.517308
7	5	5.2	What are alkalis?	Alkalis are a special type of base that dissolves in water to produce hydroxide ions OH⁻. They share characteristic properties, such as feeling soapy or slippery to the touch, turning red litmus paper blue, and having a pH above 7. Alkalis react with acids to form salts and water, and they can also react with ammonium salts and metal salts. Examples of common alkalis include sodium hydroxide, potassium hydroxide, and calcium hydroxide.	Chapter 1, Topic 5.2, Paragraph 4, Chapter 1, Topic 5.2, Paragraph 1, Chapter 1, Topic 5.2, Paragraph 2	\N	2026-04-18 09:01:42.451595
8	5	5.2	What is DNA?	DNA is not explicitly defined in the provided textbook content, but it is mentioned as having a double helix structure held together by hydrogen bonds between complementary base pairs. The content discusses the role of hydrogen bonds in DNA, but does not provide a full definition of what DNA is.	Chapter 1, Topic 5.1, Paragraph 1, Chapter 1, Topic 1.5, Paragraph 1, Chapter 1, Topic 1.5, Paragraph 3	\N	2026-04-18 09:01:55.289454
9	5	\N	What is EduTailor?	The textbook content does not mention what EduTailor is. The provided content only discusses chemistry topics such as Le Chatelier's Principle, reversible reactions, titration, and radioisotopes.	Chapter 1, Topic 4.1, Paragraph 4, Chapter 1, Topic 5.3, Paragraph 4, Chapter 1, Topic 4.6, Paragraph 2	\N	2026-04-19 06:29:34.213406
10	5	\N	What is Le Chatelier's Principle?	Le Chatelier's Principle is a fundamental principle that states if a change is made to a system at equilibrium, the system will shift in the direction that opposes that change. This means that the system will adjust to counteract the change and re-establish equilibrium. The principle applies to changes in conditions such as temperature, pressure, or concentration. It helps predict how a system at equilibrium will respond to these changes.	Chapter 1, Topic 4.1, Paragraph 4, Chapter 1, Topic 3.1, Paragraph 4, Chapter 1, Topic 4.6, Paragraph 2	\N	2026-04-19 06:30:04.600651
11	5	1.1	What is Covalent Bond?	A covalent bond is a chemical bond formed when two atoms share one or more pairs of electrons. This type of bonding typically occurs between non-metal atoms that have similar electronegativities. The shared electrons are attracted to the nuclei of both atoms, creating a strong bond that holds the atoms together. The shared pair of electrons is called a bonding pair.	Chapter 1, Topic 1.2, Paragraph 2, Chapter 1, Topic 1.2, Paragraph 1, Chapter 1, Topic 1.4, Paragraph 1	\N	2026-04-22 16:11:10.629275
12	5	1.1	What is Le Chatelier's Principle?	Le Chatelier's Principle is a fundamental principle that states if a change is made to a system at equilibrium, the system will shift in the direction that opposes that change. This means that the system will adjust to counteract the change and re-establish equilibrium. The principle applies to changes in conditions such as temperature, pressure, or concentration. It helps predict how a system at equilibrium will respond to these changes.	Chapter 1, Topic 4.6, Paragraph 2, Chapter 1, Topic 4.1, Paragraph 4, Chapter 1, Topic 3.1, Paragraph 4	\N	2026-04-22 16:12:30.163573
13	5	1.1	What is ionic bonding?	Ionic bonding is a type of chemical bond formed through the electrostatic attraction between oppositely charged ions. This occurs when electrons are transferred from one atom to another, typically from a metal to a non-metal, resulting in the formation of a positively charged cation and a negatively charged anion. The electrostatic force of attraction between these oppositely charged ions holds them together in an ionic compound. This type of bonding typically occurs between metals and non-metals due to their difference in electronegativity.	Chapter 1, Topic 1.1, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 3, Chapter 1, Topic 1.1, Paragraph 1	\N	2026-04-22 16:35:34.152882
14	5	1.1	What is covalent bonding?	This topic is not covered here, as the provided content only discusses Ionic Bonding. To learn about covalent bonding, you may need to navigate to a different section or topic in your chemistry studies.	Chapter 1, Topic 1.1, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 4, Chapter 1, Topic 1.1, Paragraph 1	\N	2026-04-22 16:35:55.85936
15	5	1.1	What is Le Chatelier's Principle?	This topic is not covered here, as the provided content only discusses Ionic Bonding. To learn about Le Chatelier's Principle, you may need to navigate to a different topic, possibly Equilibrium. The content provided here only explains the characteristics of ionic compounds, such as their crystal lattice structure and lattice energy.	Chapter 1, Topic 1.1, Paragraph 4	\N	2026-04-22 16:36:33.294093
16	5	\N	What is metallic bonding?	Metallic bonding is the type of chemical bonding that holds metal atoms together in a solid metal. It involves the release of outermost valence electrons, which are then free to move throughout the entire metallic structure, creating a lattice of positively charged metal ions surrounded by a sea of delocalized electrons. The metallic bond is the strong electrostatic attraction between the positive metal ions and the surrounding sea of delocalized electrons. This bonding is responsible for the unique properties of metals, including their mechanical, electrical, and thermal properties.	Chapter 1, Topic 1.3, Paragraph 2, Chapter 1, Topic 1.3, Paragraph 1, Chapter 1, Topic 1.3, Paragraph 3	\N	2026-04-22 16:37:32.356681
17	5	\N	Explain polar covalent bonds	A polar covalent bond is a type of covalent bond where electrons are shared unequally between two atoms due to a difference in electronegativity. This occurs when the electronegativity difference between the two atoms is moderate, typically between 0.4 and 1.7 on the Pauling scale. As a result, the atom with higher electronegativity develops a partial negative charge (delta minus), while the atom with lower electronegativity develops a partial positive charge (delta plus). This unequal sharing of electrons creates a dipole moment, which is a measure of the separation of positive and negative charges.	Chapter 1, Topic 1.4, Paragraph 3, Chapter 1, Topic 1.4, Paragraph 1, Chapter 1, Topic 1.4, Paragraph 2	\N	2026-04-22 16:38:01.769576
18	5	\N	What is the pH scale?	The pH scale is not covered in this chapter, which focuses on chemical bonding. The content provided discusses hydrogen bonding, ionic compounds, lattice energy, and bond energy, but does not mention pH scale.	Chapter 1, Topic 1.5, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 4, Chapter 1, Topic 1.6, Paragraph 1	\N	2026-04-22 16:38:19.652208
19	5	\N	What is Le Chatelier's Principle?	Le Chatelier's Principle is not covered in this chapter, which focuses on Chemical Bonding, including covalent bonds, metallic bonds, and polarity. The chapter discusses molecular geometry, Lewis structures, and electronegativity, but does not mention Le Chatelier's Principle. This principle is likely discussed in a different chapter, possibly related to chemical equilibrium.	Chapter 1, Topic 1.2, Paragraph 4, Chapter 1, Topic 1.4, Paragraph 2, Chapter 1, Topic 1.3, Paragraph 3	\N	2026-04-22 16:39:07.380741
20	5	\N	Ok, thank you!	It seems like you didn't have a question. If you have any questions about chemical bonding, I'd be happy to help.	Chapter 1, Topic 1.3, Paragraph 2, Chapter 1, Topic 1.4, Paragraph 1, Chapter 1, Topic 1.6, Paragraph 1	\N	2026-04-22 16:39:34.552207
21	5	\N	Bye!	It was nice chatting with you, but it seems you didn't have a question related to the 'Chemical Bonding' chapter. If you have any questions in the future, feel free to ask, and I'll be happy to help. Have a great day.	Chapter 1, Topic 1.5, Paragraph 3, Chapter 1, Topic 1.6, Paragraph 2, Chapter 1, Topic 1.4, Paragraph 3	\N	2026-04-22 16:39:45.193573
22	5	\N	What is metallic bonding?	Metallic bonding is the type of chemical bonding that holds metal atoms together in a solid metal. It involves the release of outermost valence electrons, which are then free to move throughout the entire metallic structure, creating a lattice of positively charged metal ions surrounded by a sea of delocalized electrons. The metallic bond is the strong electrostatic attraction between the positive metal ions and the surrounding sea of delocalized electrons. This bonding is responsible for the unique properties of metals, including their malleability, ductility, and conductivity.	Chapter 1, Topic 1.3, Paragraph 2, Chapter 1, Topic 1.3, Paragraph 1, Chapter 1, Topic 1.3, Paragraph 3	\N	2026-04-22 16:40:09.551979
23	5	3.1	What is Ionic Bonding?	I don't have information about that in the current scope. Please try rephrasing your question.	\N	\N	2026-04-22 16:52:36.582462
24	5	1.1	write print program in python	I don't have information about that in the current scope. Please try rephrasing your question.	\N	\N	2026-04-23 20:01:39.111644
25	5	1.1	What is Covalent Bond?	This topic is not covered here. The provided content only discusses Ionic Bonding, and there is no information about Covalent Bonding. I suggest you navigate to the relevant topic to learn about Covalent Bonding.	Chapter 1, Topic 1.1, Paragraph 1, Chapter 1, Topic 1.1, Paragraph 4, Chapter 1, Topic 1.1, Paragraph 2	\N	2026-04-24 18:53:21.977258
26	5	1.1	Give me some interesting facts about Ionic Bonding.	Ionic compounds have high melting and boiling points due to strong electrostatic forces between ions. They do not conduct electricity in their solid state, but become conductive when dissolved in water or melted, allowing the ions to become mobile. The formation of ionic bonds typically occurs between metals and non-metals, resulting in a strong, rigid crystal lattice structure. Examples of ionic compounds include sodium chloride, magnesium oxide, and calcium chloride.	Chapter 1, Topic 1.1, Paragraph 1, Chapter 1, Topic 1.1, Paragraph 2, Chapter 1, Topic 1.1, Paragraph 3	\N	2026-04-24 20:14:37.215883
27	5	1.1	What is ionization energy?	Ionization energy is not explicitly defined in the provided content, but it is mentioned that metals such as sodium have low ionization energies, which means they readily lose their valence electrons. This suggests that ionization energy is related to the ease with which an atom loses electrons. However, a precise definition is not provided in the given text.	Chapter 1, Topic 1.1, Paragraph 4, Chapter 1, Topic 1.1, Paragraph 1, Chapter 1, Topic 1.1, Paragraph 2	\N	2026-04-24 20:20:21.315705
28	5	1.1	What is electronegativity?	This topic is not covered in detail here, but it is mentioned that the formation of ionic bonds occurs between metals and non-metals due to their difference in electronegativity. The textbook content does not provide a definition of electronegativity, but it implies that metals have low electronegativity and non-metals have high electronegativity. You may want to navigate to a topic that specifically covers electronegativity for a more detailed explanation.	Chapter 1, Topic 1.1, Paragraph 4, Chapter 1, Topic 1.1, Paragraph 1, Chapter 1, Topic 1.1, Paragraph 2	\N	2026-04-24 20:20:45.156861
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topics (topic_id, chapter_id, topic_name, paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5, visual_type, visual_path, visual_narration, urdu_paragraph_1, urdu_paragraph_2, urdu_paragraph_3, urdu_paragraph_4, urdu_paragraph_5, audio_en_path, mindmap_json, created_at, updated_at) FROM stdin;
1.3	1	Metallic Bonding	Metallic bonding is the type of chemical bonding that holds metal atoms together in a solid metal. In a metal, each atom releases its outermost valence electrons, which are then free to move throughout the entire metallic structure. This creates a lattice of positively charged metal ions surrounded by a sea or cloud of delocalized electrons that do not belong to any particular atom. The metallic bond is the strong electrostatic attraction between the positive metal ions and the surrounding sea of delocalized electrons.	The presence of delocalized electrons directly explains the excellent electrical and thermal conductivity of metals. When a voltage is applied across a metal, the free electrons can move throughout the structure in a single direction, constituting an electric current. Similarly, when one part of a metal is heated, the mobile electrons rapidly transfer kinetic energy to other parts of the structure, explaining why metals are good thermal conductors. The strength of the metallic bond depends on the number of delocalized electrons per atom and the charge density of the metal ions.	The unique mechanical properties of metals including malleability and ductility are also explained by the metallic bonding model. Metals can be hammered into sheets which is malleability or drawn into wires which is ductility because the layers of metal ions can slide past one another without breaking the metallic bond. As one layer moves relative to another, the delocalized electrons simply rearrange to maintain the bonding between the new arrangement of ions. This is in sharp contrast to ionic compounds, where attempting to deform the lattice brings like-charged ions close together, causing repulsion and fracture.	\N	\N	animation	/api/media/animations/1.3_animation.mp4	Notice how each metal atom in the lattice releases its outermost valence electrons into the structure. Watch as these electrons become delocalized, forming a mobile sea that moves freely throughout the entire metal rather than belonging to any single atom. Observe that what remains are positively charged metal ions arranged in an orderly lattice pattern. See how the strong electrostatic attraction between these positive ions and the surrounding electron sea creates the metallic bond holding the structure together.\n\nPay attention to what happens when voltage is applied across the metal. You can see that the delocalized electrons move in one direction, creating an electric current and explaining metals' excellent electrical conductivity. Similarly, observe how these mobile electrons rapidly transfer kinetic energy when heat is applied, demonstrating why metals conduct thermal energy so effectively.\n\nNow watch what happens when force is applied to deform the metal. Notice how the layers of metal ions slide past one another without the structure breaking apart. See how the electron sea simply rearranges itself to maintain bonding with the new positions of the ions. This flexibility explains why metals are malleable and ductile. Look at how this contrasts sharply with ionic compounds, where shifting layers would bring like charges together, causing repulsion and fracture rather than smooth deformation.	دھاتی بندھن وہ قسم کا کیمیائی بندھن ہے جو ٹھوس دھات میں دھاتی ایٹم کو ایک ساتھ رکھتا ہے۔ دھات میں، ہر ایٹم اپنے بیرونی ترین والنس الیکٹرانوں کو چھوڑ دیتا ہے، جو پھر پوری دھاتی ساخت میںحرکت کرنے کے لیے آزاد ہوتے ہیں۔ یہ مثبت چارج والے دھاتی آئنوں کا ایک جال بناتا ہے جو غیر مقامی الیکٹرانوں کے سمندر یا بادل سے گھira ہوا ہے جو کسی خاص ایٹم سے تعلق نہیں رکھتے۔ دھاتی بندھن مثبت دھاتی آئنوں اور周围 غیر مقامی الیکٹرانوں کے سمندر کے درمیان مضبوط الیکٹرو سٹیٹک کشش ہے۔	غیر مقامی الیکٹرانوں کی موجودگی دھاتوں کی عمدہ برقی اور حرارتی موصلیت کی واضح وضاحت کرتی ہے۔ جب دھات پر وولٹیج لگایا جاتا ہے، تو آزاد الیکٹران ایک ہی سمت میں پوری ساخت میں حرکت کر سکتے ہیں، جو برقی کرنٹ بناتے ہیں۔ اسی طرح، جب دھات کا ایک حصہ گرم کیا جاتا ہے، تو متحرک الیکٹران تیزی سے دوسرے حصوں کو حرکی توانائی منتقل کرتے ہیں، جو یہ وضاحت کرتا ہے کہ دھات اچھی حرارتی موصل ہیں۔ دھاتی بندھن کی طاقت ایٹم فی الیکٹرانوں کی تعداد اور دھاتی آئنوں کی چارج کثافت پر منحصر ہے۔	دھاتوں کی منفرد مکانیکی خصوصیات، بشمول ملائمت اور لچک، کو بھی دھاتی بندھن ماڈل سے وضاحت دی جا سکتی ہے۔ دھاتی آئنوں کی تہیں ایک دوسرے کے اوپر سے گزر سکتی ہیں بغیر دھاتی بندھن کو توڑے، کیونکہ دھاتوں کو چادروں میں بھی ہموار کیا جا سکتا ہے جو ملائمت ہے یا تاروں میں کھینچا جا سکتا ہے جو لچک ہے۔ جب ایک تہہ دوسری کے相対 حرکت کرتی ہے، تو غیر مقامی الیکٹران آئنوں کی نئی ترتیب کے درمیان بندھن کو برقرار رکھنے کے لیے دوبارہ ترتیب دیتے ہیں۔ یہ آئنک مرکبات سے تیز تضاد ہے، جہاں جال کو biến کرنے کی کوشش یکساں چارج والے آئنوں کو ایک ساتھ لاتی ہے، جس سے دھکاوہ اور ٹوٹ پھوٹ ہوتی ہے۔	\N	\N	/api/media/audio/1.3_en.mp3	{"markdown": "# Metallic Bonding\\n\\n## Definition\\n### Structure\\n- Metal ions lattice\\n- Delocalized electron sea\\n### Bonding Force\\n- Electrostatic attraction\\n- Positive ions and electrons\\n\\n## Key Properties\\n### Electrical Conductivity\\n- Mobile electrons flow\\n- Carry electric current\\n### Thermal Conductivity\\n- Electrons transfer energy\\n- Rapid heat distribution\\n\\n## Mechanical Properties\\n### Malleability\\n- Hammered into sheets\\n- Layers slide easily\\n### Ductility\\n- Drawn into wires\\n- Bonds remain intact\\n\\n## Bond Strength Factors\\n- Number of electrons\\n- Ion charge density\\n\\n## Exam Tips\\n- Explain electron movement\\n- Compare with ionic\\n- Link structure to properties"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
2.2	2	Isotopes	Isotopes are atoms of the same element that have the same number of protons but different numbers of neutrons in their nuclei. Because they have the same number of protons, isotopes of an element have the same atomic number and the same chemical properties. However, because they have different numbers of neutrons, they have different mass numbers and therefore different masses. The term isotope comes from the Greek words meaning equal place, referring to the fact that isotopes occupy the same position in the periodic table.	Carbon provides a well-known example of isotopes. Carbon-12 has 6 protons and 6 neutrons, giving it a mass number of 12. Carbon-13 has 6 protons and 7 neutrons, giving it a mass number of 13. Carbon-14 has 6 protons and 8 neutrons, giving it a mass number of 14. All three are carbon because they all have 6 protons. Another important example is hydrogen, which has three isotopes: ordinary hydrogen called protium with 1 proton and 0 neutrons, deuterium with 1 proton and 1 neutron, and tritium with 1 proton and 2 neutrons.	The relative atomic mass of an element takes into account the existence of isotopes. It is the weighted average mass of all naturally occurring isotopes of an element relative to one-twelfth the mass of a carbon-12 atom. For example, chlorine has two main isotopes: chlorine-35 which makes up about 75 percent of natural chlorine and chlorine-37 which makes up about 25 percent. The relative atomic mass of chlorine is therefore approximately 35.5, which is the weighted average of these two isotopes. This explains why the relative atomic masses of many elements are not whole numbers.	Some isotopes are radioactive, meaning their nuclei are unstable and spontaneously decay, emitting radiation in the process. These are called radioisotopes or radioactive isotopes. Carbon-14 is a well-known radioisotope used in radiocarbon dating to determine the age of ancient organic materials. Uranium-235 and uranium-238 are radioisotopes used in nuclear energy production. In medicine, technetium-99m is widely used as a radioactive tracer in medical imaging. The stability of an isotope depends on the ratio of neutrons to protons in the nucleus — too many or too few neutrons relative to protons leads to instability.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
1.6	1	Bond Energy and Bond Length	Bond energy, also called bond enthalpy, is the amount of energy required to break one mole of a particular type of bond in gaseous molecules. It is a measure of bond strength — the stronger the bond, the more energy is required to break it. Bond energy is always a positive value because breaking bonds requires energy input, making it an endothermic process. Conversely, when bonds form, energy is released in an exothermic process. Different types of bonds have different bond energies. For example, the C-H bond in methane has a bond energy of approximately 413 kJ/mol, while the C-C bond has about 348 kJ/mol.	Bond length is the average distance between the nuclei of two bonded atoms. It is determined by a balance between attractive and repulsive forces — the nuclei and electrons attract each other, but the nuclei repel each other as do the electrons. Bond length is typically measured in picometers or angstroms. There is an important inverse relationship between bond energy and bond length — shorter bonds are generally stronger and have higher bond energies, while longer bonds are weaker with lower bond energies. This relationship exists because in shorter bonds, the bonding electrons are held more tightly between the nuclei, creating a stronger electrostatic attraction.	The relationship between bond order, bond length, and bond energy can be observed in molecules with single, double, and triple bonds. Consider carbon-carbon bonds: a C-C single bond has a length of about 154 pm and bond energy of 348 kJ/mol; a C=C double bond is shorter at 134 pm and stronger at 614 kJ/mol; and a C≡C triple bond is even shorter at 120 pm and strongest at 839 kJ/mol. This trend occurs because as more electron pairs are shared between atoms, the bond becomes shorter and stronger. These relationships are fundamental to understanding chemical reactivity, as bonds with lower bond energies are generally easier to break and therefore more reactive.	Bond energy and bond length data have practical applications in chemistry. They can be used to estimate the enthalpy change of reactions by calculating the difference between energy required to break bonds in reactants and energy released when forming bonds in products. This is particularly useful for reactions where direct measurement is difficult. Additionally, comparing bond energies helps explain why certain reactions occur more readily than others. For instance, the high bond energy of the N≡N triple bond in nitrogen gas explains why nitrogen is relatively unreactive under normal conditions, despite being abundant in the atmosphere.	\N	animation	/api/media/animations/1.6_animation.mp4	Notice how breaking a chemical bond requires energy input, making bond energy always a positive value. Watch as the animation highlights that stronger bonds demand more energy to break—this is why bond energy serves as a direct measure of bond strength. Observe the example of methane, where a C-H bond requires approximately 413 kJ/mol to break, compared to 348 kJ/mol for a C-C bond.\n\nPay attention to how bond length represents the average distance between two bonded nuclei, balanced by attractive and repulsive forces acting simultaneously. See how shorter bonds correlate with higher bond energies—this inverse relationship occurs because electrons in shorter bonds are held more tightly between nuclei, creating stronger electrostatic attraction.\n\nLook at the progression from single to triple carbon-carbon bonds. Notice how the C-C single bond measures 154 pm with an energy of 348 kJ/mol, while the C=C double bond shortens to 134 pm and strengthens to 614 kJ/mol. Watch as the C≡C triple bond becomes even shorter at 120 pm and strongest at 839 kJ/mol. You can see that as more electron pairs are shared, bonds become progressively shorter and stronger.\n\nObserve how these principles explain chemical reactivity—bonds with lower energies break more easily. Notice the nitrogen molecule's triple bond, whose high energy of 839 kJ/mol makes nitrogen remarkably unreactive despite its atmospheric abundance.	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
2.4	2	Proton Number and Nucleon Number	The proton number, also called the atomic number, is the number of protons in the nucleus of an atom. It is represented by the symbol Z. The proton number uniquely identifies an element — every atom of the same element has the same number of protons. For example, all carbon atoms have 6 protons, all oxygen atoms have 8 protons, and all iron atoms have 26 protons. If the proton number changes, the atom becomes a different element entirely. The proton number also equals the number of electrons in a neutral atom.	The nucleon number, also called the mass number, is the total number of protons and neutrons in the nucleus of an atom. It is represented by the symbol A. Nucleons are the particles found in the nucleus — both protons and neutrons are nucleons. The number of neutrons in an atom can be calculated by subtracting the proton number from the nucleon number: neutrons equals A minus Z. For example, an atom of sodium has a proton number of 11 and a nucleon number of 23, so it has 23 minus 11 equals 12 neutrons.	Atoms are represented using a standard notation that shows both the proton number and nucleon number. In this notation, the chemical symbol of the element is written with the nucleon number as a superscript on the upper left and the proton number as a subscript on the lower left. For example, carbon-12 is written with 12 as the superscript and 6 as the subscript before the symbol C. This notation provides complete information about the composition of an atom's nucleus, allowing the number of protons, neutrons, and electrons to be determined immediately.	Understanding proton number and nucleon number is essential for working with isotopes and nuclear reactions. When writing equations for nuclear reactions, the total proton numbers and nucleon numbers must be balanced on both sides of the equation, similar to how atoms are balanced in chemical equations. The proton number determines an element's position in the periodic table — elements are arranged in order of increasing proton number. The discovery that elements are characterized by their proton number, rather than their mass, was one of the most important developments in the history of chemistry and physics.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
2.5	2	Periodic Table and Electron Shells	The modern periodic table arranges all known elements in order of increasing atomic number, organized into rows called periods and columns called groups. There are currently 118 confirmed elements in the periodic table. Each period corresponds to a new electron shell being filled. Period 1 contains elements whose electrons occupy only the first shell. Period 2 contains elements filling the second shell, and so on. This arrangement means that elements in the same period have electrons in the same number of shells.	Elements in the same group or column of the periodic table have the same number of valence electrons and consequently similar chemical properties. Group 1 elements, called alkali metals, all have one valence electron and are highly reactive metals that react vigorously with water. Group 7 elements, called halogens, all have seven valence electrons and are reactive non-metals. Group 0 or Group 18 elements, the noble gases, have completely filled outer shells with either 2 electrons for helium or 8 electrons for the rest, making them extremely unreactive.	The periodic table is divided into metals, non-metals, and metalloids. Metals occupy the left and center of the table and make up about 75 percent of all elements. They are typically shiny, good conductors of heat and electricity, malleable, and ductile. Non-metals are found on the right side of the table and generally have opposite properties to metals — they are poor conductors, brittle in solid form, and have lower melting points. Metalloids or semi-metals such as silicon and germanium have properties intermediate between metals and non-metals and are particularly important in semiconductor technology.	Trends in properties across periods and down groups can be explained by changes in electronic configuration. Across a period from left to right, the atomic radius generally decreases because more protons are added to the nucleus while electrons are added to the same shell, pulling all electrons closer. Down a group, atomic radius increases because each successive element has an additional electron shell. Ionization energy, which is the energy needed to remove an electron from an atom, generally increases across a period and decreases down a group. These trends make the periodic table a powerful predictive tool for understanding and comparing the properties of elements.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
3.4	3	Gas Laws	The gas laws describe the mathematical relationships between the pressure, volume, and temperature of a fixed amount of gas. Boyle's Law states that at constant temperature, the pressure of a fixed mass of gas is inversely proportional to its volume. This means that if the volume of a gas is halved, its pressure doubles, and vice versa. Mathematically, pressure times volume equals a constant, or P₁V₁ equals P₂V₂. This law can be explained using particle theory — if the volume decreases, the particles hit the walls more frequently, increasing the pressure.	Charles's Law states that at constant pressure, the volume of a fixed mass of gas is directly proportional to its absolute temperature measured in Kelvin. This means that if the temperature doubles, the volume also doubles. Mathematically, volume divided by temperature equals a constant, or V₁ divided by T₁ equals V₂ divided by T₂. It is important to use the Kelvin temperature scale, where 0 Kelvin is absolute zero, the theoretical point at which all particle motion stops. To convert from Celsius to Kelvin, add 273 to the Celsius temperature.	The Pressure Law states that at constant volume, the pressure of a fixed mass of gas is directly proportional to its absolute temperature in Kelvin. If the temperature increases, the particles move faster, hit the walls harder and more frequently, and the pressure increases. Combining all three gas laws gives the Combined Gas Law: P₁V₁ divided by T₁ equals P₂V₂ divided by T₂. This equation allows the calculation of a new pressure, volume, or temperature when any two of these variables change simultaneously, making it very useful for solving gas law problems.	The Ideal Gas Law combines the gas laws with the amount of gas in moles. It states that pressure times volume equals the number of moles times the gas constant R times the absolute temperature, written as PV equals nRT. This equation applies to ideal gases — theoretical gases whose particles have no volume and no intermolecular forces. Real gases behave most like ideal gases at low pressures and high temperatures, where the particles are far apart. The gas laws have many practical applications, including the design of engines, refrigeration systems, and the understanding of atmospheric pressure and weather patterns.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
3.5	3	Intermolecular Forces	Intermolecular forces are the forces of attraction that exist between molecules. They are distinct from intramolecular forces, which are the bonds within molecules such as covalent bonds. Intermolecular forces are generally much weaker than covalent or ionic bonds, but they play a crucial role in determining the physical properties of substances such as melting points, boiling points, and solubility. The three main types of intermolecular forces in order of increasing strength are London dispersion forces, dipole-dipole forces, and hydrogen bonding.	London dispersion forces, also called van der Waals forces, are the weakest type of intermolecular force and exist between all molecules, whether polar or non-polar. They arise from temporary, instantaneous dipoles that form when the electron cloud of a molecule becomes momentarily unevenly distributed. This temporary dipole induces a dipole in neighboring molecules, creating a weak attractive force. London forces increase with increasing molecular size because larger molecules have more electrons, making larger and more easily polarized electron clouds. This explains why larger non-polar molecules like iodine have higher boiling points than smaller ones like hydrogen.	Dipole-dipole forces are attractions between polar molecules that have permanent dipole moments. The partially positive end of one polar molecule is attracted to the partially negative end of a neighboring polar molecule. These forces are stronger than London dispersion forces but weaker than hydrogen bonds. Polar molecules like hydrogen chloride HCl and sulfur dioxide SO₂ experience dipole-dipole forces. The strength of dipole-dipole forces increases with the magnitude of the dipole moment — more polar molecules experience stronger dipole-dipole interactions and consequently have higher boiling points than less polar molecules of similar size.	The relative strength of intermolecular forces has a direct impact on the physical properties of substances. Substances with only London dispersion forces, such as non-polar molecules and noble gases, tend to have low boiling points and exist as gases at room temperature unless the molecules are large. Substances with dipole-dipole forces have higher boiling points. Substances with hydrogen bonding have unusually high boiling points relative to their molecular mass, explaining why water has a boiling point of 100°C despite being a small molecule. The type and strength of intermolecular forces also affects viscosity, surface tension, and miscibility of liquids.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.1	4	Types of Chemical Reactions	Chemical reactions can be classified into several main types based on the changes that occur. A synthesis or combination reaction is one in which two or more reactants combine to form a single product. For example, iron and sulfur react when heated to form iron sulfide. A decomposition reaction is the opposite — a single compound breaks down into two or more simpler substances. For example, calcium carbonate decomposes on heating to form calcium oxide and carbon dioxide. These two reaction types are essentially reverse processes of each other.	A displacement or substitution reaction occurs when a more reactive element displaces or pushes out a less reactive element from its compound. Single displacement reactions involve one element displacing another from a compound. For example, zinc displaces copper from copper sulfate solution because zinc is more reactive than copper. Double displacement reactions, also called precipitation reactions, involve two compounds exchanging ions to form two new compounds, often with one product being an insoluble precipitate. For example, mixing silver nitrate solution with sodium chloride solution produces a white precipitate of silver chloride.	Oxidation and reduction reactions, collectively called redox reactions, are extremely important in chemistry. Oxidation was originally defined as the gain of oxygen or loss of hydrogen, while reduction was the loss of oxygen or gain of hydrogen. The modern definition is broader: oxidation is the loss of electrons and reduction is the gain of electrons. These two processes always occur simultaneously — when one substance is oxidized, another is reduced. A useful memory aid is OIL RIG, which stands for Oxidation Is Loss of electrons, Reduction Is Gain of electrons.	Reversible reactions are reactions that can proceed in both the forward and reverse directions. They are indicated by a double arrow in chemical equations. When a reversible reaction occurs in a closed system, the rates of the forward and reverse reactions eventually become equal, and the concentrations of reactants and products remain constant. This state is called dynamic equilibrium. Le Chatelier's Principle states that if a system at equilibrium is subjected to a change in conditions such as temperature, pressure, or concentration, the system will shift to oppose that change and re-establish equilibrium.	Neutralization reactions occur when an acid reacts with a base to form a salt and water. This is one of the most important reaction types in chemistry and has numerous practical applications. The general equation for a neutralization reaction is acid plus base produces salt plus water. For example, hydrochloric acid reacting with sodium hydroxide produces sodium chloride and water. Combustion reactions involve the rapid reaction of a substance with oxygen to produce heat and light. Complete combustion of a hydrocarbon produces carbon dioxide and water, while incomplete combustion can produce carbon monoxide or carbon particles, which are harmful pollutants.	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.2	4	Energy Changes in Reactions	All chemical reactions involve energy changes. In most reactions, energy is transferred between the reacting chemicals and their surroundings in the form of heat. An exothermic reaction is one that releases heat energy to the surroundings, causing the temperature of the surroundings to increase. Examples of exothermic reactions include combustion, neutralization, and many oxidation reactions. In exothermic reactions, the products have less energy than the reactants, and the difference in energy is released to the surroundings. The energy change is represented by a negative value of enthalpy change, written as a negative delta H.	An endothermic reaction is one that absorbs heat energy from the surroundings, causing the temperature of the surroundings to decrease. Examples include thermal decomposition reactions such as the decomposition of calcium carbonate, the dissolving of ammonium nitrate in water, and photosynthesis. In endothermic reactions, the products have more energy than the reactants, and the extra energy is absorbed from the surroundings. The energy change is represented by a positive value of enthalpy change. Everyday applications of endothermic reactions include cold packs used for sports injuries, which feel cold because they absorb heat from the skin.	Energy level diagrams, also called reaction profile diagrams, are used to represent the energy changes in chemical reactions. In an exothermic reaction, the products are drawn at a lower energy level than the reactants, and the difference in height represents the energy released. In an endothermic reaction, the products are drawn at a higher energy level than the reactants. All reaction profiles show a peak called the activation energy — this is the minimum energy that reacting particles must have before they can react successfully. A catalyst lowers the activation energy, providing an alternative reaction pathway with a lower energy barrier.	Bond breaking and bond forming are the underlying processes responsible for energy changes in reactions. Breaking chemical bonds always requires energy input and is endothermic. Forming chemical bonds always releases energy and is exothermic. In a reaction, bonds in the reactants are broken and new bonds are formed in the products. If more energy is released in forming the new bonds than was needed to break the old bonds, the overall reaction is exothermic. If more energy is required to break bonds than is released in forming new bonds, the overall reaction is endothermic. This bond energy approach allows the enthalpy change of a reaction to be estimated from bond energy data.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.4	4	Oxidation and Reduction	Oxidation and reduction are complementary processes that always occur together in what are called redox reactions. The traditional definition describes oxidation as the gain of oxygen or loss of hydrogen, and reduction as the loss of oxygen or gain of hydrogen. For example, when magnesium burns in oxygen, the magnesium is oxidized because it gains oxygen to form magnesium oxide. When copper oxide is heated with hydrogen, the copper oxide is reduced because it loses oxygen to form copper metal, while the hydrogen is simultaneously oxidized to water.	The electron transfer definition provides a more comprehensive understanding of redox reactions. Oxidation is defined as the loss of electrons, and reduction is defined as the gain of electrons. These two processes always occur simultaneously — the electrons lost by one substance must be gained by another. The substance that loses electrons is called the reducing agent because it causes the other substance to be reduced by donating electrons to it. The substance that gains electrons is called the oxidizing agent because it causes the other substance to be oxidized by accepting electrons from it.	Oxidation numbers, also called oxidation states, provide a way to track electron transfer in redox reactions. The oxidation number represents the charge an atom would have if the bonding electrons were assigned to the more electronegative atom. Rules for assigning oxidation numbers include: the oxidation number of a pure element is zero; the oxidation number of a monoatomic ion equals its charge; oxygen usually has an oxidation number of minus two; hydrogen usually has an oxidation number of plus one. In a redox reaction, the substance being oxidized shows an increase in oxidation number, while the substance being reduced shows a decrease.	Electrochemistry provides a practical application of redox chemistry. In electrolysis, an electric current is passed through a molten or dissolved ionic compound to cause a non-spontaneous redox reaction. At the cathode which is the negative electrode, reduction occurs as positive ions gain electrons. At the anode which is the positive electrode, oxidation occurs as negative ions lose electrons. Electrolysis is used industrially to extract reactive metals like aluminum from their ores, to purify copper, and to electroplate metals. The reactivity series of metals is directly related to their tendency to be oxidized, with more reactive metals being more easily oxidized.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.6	4	Chemical Equilibrium	Chemical equilibrium is a state reached in a reversible reaction when the rate of the forward reaction equals the rate of the reverse reaction. At this point, the concentrations of reactants and products remain constant over time, but the reaction has not stopped — it is a dynamic equilibrium where both forward and reverse reactions continue to occur at equal rates. Equilibrium can only be reached in a closed system where reactants and products cannot escape. The position of equilibrium describes whether the equilibrium mixture contains more reactants or more products at equilibrium.	Le Chatelier's Principle is a fundamental principle used to predict how a system at equilibrium responds to changes in conditions. It states that if a change is made to a system at equilibrium, the system will shift in the direction that opposes that change. If the concentration of a reactant is increased, the equilibrium shifts to the right to use up some of the added reactant and produce more products. If the concentration of a product is increased, the equilibrium shifts to the left. Removing a reactant or product has the opposite effect. A catalyst does not shift the position of equilibrium — it only helps the system reach equilibrium faster.	Temperature changes affect equilibrium position by favoring either the forward or reverse reaction depending on whether the reaction is exothermic or endothermic. For an exothermic reaction, increasing the temperature shifts the equilibrium to the left, favoring the reverse endothermic reaction and reducing the yield of products. Decreasing the temperature shifts the equilibrium to the right, increasing the yield. For an endothermic reaction, the opposite applies. Pressure changes affect equilibrium in reactions involving gases — increasing pressure favors the side with fewer moles of gas, shifting the equilibrium toward fewer gas molecules.	The Haber process for manufacturing ammonia is an important industrial application of equilibrium principles. Nitrogen and hydrogen gases react reversibly to form ammonia in an exothermic reaction. To maximize ammonia yield, low temperature and high pressure would be favored by Le Chatelier's Principle. However, low temperature makes the reaction too slow, so a compromise temperature of around 450°C is used with an iron catalyst to achieve an acceptable rate. High pressure of around 200 atmospheres is used to shift equilibrium toward ammonia. The ammonia is continuously removed from the equilibrium mixture, which causes the equilibrium to shift right to produce more ammonia, further improving yield.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
5.1	5	Acids and Their Properties	An acid is a substance that produces hydrogen ions H⁺ when dissolved in water. More precisely, acids donate protons which are hydrogen ions to other substances — this is the Brønsted-Lowry definition of an acid. Common laboratory acids include hydrochloric acid HCl, sulfuric acid H₂SO₄, and nitric acid HNO₃. These are all strong acids, meaning they fully dissociate in water to produce hydrogen ions. Weak acids such as ethanoic acid CH₃COOH and carbonic acid H₂CO₃ only partially dissociate in water, producing fewer hydrogen ions and thus lower acidity.	Acids share a set of characteristic chemical properties that can be used to identify them. Acids have a sour taste, though tasting laboratory chemicals is extremely dangerous and should never be done. Acids turn blue litmus paper red and have a pH below 7. Acids react with metals above hydrogen in the reactivity series to produce a salt and hydrogen gas. For example, zinc reacts with hydrochloric acid to produce zinc chloride and hydrogen. Acids react with metal oxides and metal hydroxides to produce a salt and water only. Acids react with metal carbonates and metal hydrogencarbonates to produce a salt, water, and carbon dioxide gas.	The pH scale is a measure of the acidity or alkalinity of a solution. It runs from 0 to 14, with 7 being neutral. Values below 7 indicate acidic solutions, with lower values indicating stronger acids — a solution of pH 1 is more acidic than a solution of pH 5. Values above 7 indicate alkaline solutions, with higher values indicating stronger alkalis. The pH scale is logarithmic, meaning each unit change in pH represents a tenfold change in hydrogen ion concentration. pH is measured using indicators, pH paper, or a pH meter. Universal indicator changes through a range of colors corresponding to different pH values.	The concentration of an acid affects its reactivity. Concentrated acids have a higher number of acid molecules per unit volume and react more vigorously than dilute acids. The strength of an acid is different from its concentration — strength refers to the degree of dissociation, while concentration refers to the amount of acid dissolved per unit volume. A concentrated weak acid can be less reactive than a dilute strong acid. Strong acids are completely ionized in solution, while weak acids reach an equilibrium between ionized and un-ionized forms. This distinction is important in understanding the behavior of acids in chemical reactions and in biological systems.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
5.2	5	Bases and Alkalis	A base is a substance that can accept a proton from an acid, or in simpler terms, a substance that neutralizes an acid to form a salt and water only. Metal oxides and metal hydroxides are common examples of bases. An alkali is a special type of base that dissolves in water to produce hydroxide ions OH⁻. All alkalis are bases, but not all bases are alkalis — for example, copper oxide is a base but does not dissolve in water and so is not an alkali. Common alkalis include sodium hydroxide NaOH, potassium hydroxide KOH, calcium hydroxide Ca(OH)₂, and ammonia solution NH₃.	Alkalis share characteristic properties that distinguish them from acids. Alkalis feel soapy or slippery to the touch due to their reaction with oils on the skin, though touching concentrated alkalis is dangerous. Alkalis turn red litmus paper blue and have a pH above 7. Alkalis react with acids in neutralization reactions to form salts and water. Alkalis react with ammonium salts when heated to produce a salt, water, and ammonia gas — this reaction is used as a laboratory test for ammonium ions. Alkalis also react with solutions of metal salts to precipitate metal hydroxides, many of which are colored and can be used to identify metal ions.	Strong and weak bases differ in the extent to which they ionize in water. Strong bases like sodium hydroxide and potassium hydroxide are fully ionized in solution, producing a high concentration of hydroxide ions. Weak bases like ammonia solution are only partially ionized, producing fewer hydroxide ions and thus a lower pH. The strength of a base determines its reactivity — strong bases react more vigorously with acids than weak bases of the same concentration. In the Brønsted-Lowry theory, a base is any substance that accepts a proton, which broadens the definition beyond just hydroxide-producing substances.	Bases and alkalis have many important practical applications. Sodium hydroxide is used in the manufacture of soap through a process called saponification, where fats and oils react with alkali to produce glycerol and soap molecules. Calcium hydroxide, known as slaked lime, is used in agriculture to neutralize acidic soils and improve crop yields. Magnesium hydroxide and aluminum hydroxide are used in antacid medicines to neutralize excess stomach acid and relieve indigestion. Ammonia solution is used as a cleaning agent. Understanding the properties of bases and alkalis is therefore important not just in chemistry but in everyday applications and industry.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
5.3	5	Neutralization and Salts	Neutralization is the reaction between an acid and a base to produce a salt and water. The hydrogen ions from the acid react with the hydroxide ions from the base to form water molecules. In ionic terms, the neutralization reaction can be written as H⁺ plus OH⁻ producing H₂O. The other ions present form the salt. The resulting solution is neutral only if the acid and base are present in exactly the right proportions — the equivalence point. Neutralization reactions are exothermic, releasing heat energy, which is why mixing a strong acid with a strong alkali causes a noticeable temperature rise.	A salt is an ionic compound formed when the hydrogen ions of an acid are replaced by metal ions or ammonium ions. The name of a salt consists of two parts: the metal or ammonium part from the base and the acid part from the acid. Hydrochloric acid produces chloride salts, sulfuric acid produces sulfate salts, nitric acid produces nitrate salts, and carbonic acid produces carbonate salts. For example, hydrochloric acid reacting with sodium hydroxide produces sodium chloride, commonly known as table salt. Sulfuric acid reacting with copper oxide produces copper sulfate.	Salts can be prepared by several different methods depending on the properties of the salt required. Soluble salts are prepared by reacting an acid with an excess of a metal, metal oxide, metal hydroxide, or metal carbonate, then filtering off the excess solid and evaporating the filtrate to crystallize the salt. Insoluble salts are prepared by mixing solutions of two soluble salts that react together to form an insoluble precipitate — this is called a precipitation reaction. For example, lead sulfate can be prepared by mixing lead nitrate solution with sodium sulfate solution. The precipitate is filtered, washed, and dried.	Titration is a precise laboratory technique used to determine the exact volume of one solution needed to react completely with a known volume of another solution. In an acid-base titration, a measured volume of acid is placed in a conical flask with an indicator. Alkali is added from a burette drop by drop until the indicator changes color at the end point, showing that neutralization is complete. The volume of alkali used, called the titre, is recorded. By repeating the titration without the indicator, a pure neutral salt solution can be obtained and then crystallized. Titration allows the precise preparation of pure salts and accurate determination of solution concentrations.	\N	animation	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
5.4	5	The pH Scale and Indicators	The pH scale is a quantitative measure of the acidity or alkalinity of a solution, ranging from 0 to 14 under standard conditions. The scale is based on the concentration of hydrogen ions in solution. A neutral solution, such as pure water at 25°C, has a pH of exactly 7, meaning that the concentration of hydrogen ions equals the concentration of hydroxide ions. Acidic solutions have a pH below 7 because they contain more hydrogen ions than hydroxide ions. Alkaline solutions have a pH above 7 because they contain more hydroxide ions than hydrogen ions.	The pH scale is logarithmic, which means each whole number change in pH corresponds to a tenfold change in hydrogen ion concentration. A solution of pH 3 has ten times more hydrogen ions than a solution of pH 4, and one hundred times more hydrogen ions than a solution of pH 5. This logarithmic nature means that even small changes in pH represent large changes in acidity. For example, the pH of human blood is maintained very precisely between 7.35 and 7.45 — a drop to pH 7.0 would be life-threatening. The logarithmic scale allows a very wide range of hydrogen ion concentrations to be expressed as a simple number between 0 and 14.	Indicators are substances that change color depending on the pH of the solution they are in. They are used to determine whether a solution is acidic, neutral, or alkaline. Litmus is one of the most common indicators — it turns red in acid and blue in alkali, but does not show the actual pH value. Universal indicator is a mixture of several indicators that shows a range of colors corresponding to different pH values: red and orange for strong and weak acids, green for neutral, and blue and purple for weak and strong alkalis. A pH meter gives a precise digital reading of pH and is more accurate than color indicators.	Different indicators are suitable for different purposes in titrations. The choice of indicator depends on the nature of the acid and base being used. Phenolphthalein is colorless in acid and pink in alkali, making it suitable for strong acid-strong base titrations. Methyl orange is red in acid and yellow in alkali and is more suitable when a strong acid is being titrated against a weak base. Using the wrong indicator can give inaccurate results because different indicators change color at different pH values. In acid-base titrations, the indicator should change color sharply at the equivalence point, which is where the acid and base have exactly neutralized each other.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
5.5	5	Preparation and Uses of Salts	The method used to prepare a salt depends on whether the salt is soluble or insoluble in water, and on the reactivity of the metal involved. For soluble salts that contain a reactive metal such as zinc or iron, the salt can be prepared by reacting the metal directly with a dilute acid. The metal is added in excess to ensure all the acid is used up, then the excess metal is filtered off, and the salt solution is evaporated to produce crystals of the pure salt. For example, zinc sulfate can be prepared by reacting zinc with dilute sulfuric acid.	Soluble salts containing metals that do not react with dilute acids, such as copper, are prepared using the metal oxide or metal carbonate instead. Copper sulfate is prepared by reacting excess copper oxide or copper carbonate with dilute sulfuric acid. The excess copper compound is filtered off, and the filtrate is evaporated. Another method for preparing soluble salts is neutralization — an acid is titrated against an alkali using an indicator to find the exact volumes needed for neutralization, then the experiment is repeated without indicator to obtain a pure salt solution, which is then crystallized.	Insoluble salts are prepared by precipitation — mixing two solutions that contain the required ions. When the two solutions are mixed, the insoluble salt forms immediately as a precipitate. For example, barium sulfate, which is insoluble, can be prepared by mixing barium chloride solution with sodium sulfate solution. The precipitate is collected by filtration, washed with distilled water to remove any soluble impurities, and then dried. This method is also used in qualitative analysis to identify the presence of specific ions — for example, adding silver nitrate solution to a solution containing chloride ions produces a white precipitate of silver chloride.	Salts have enormous importance in industry, agriculture, and everyday life. Sodium chloride is used in the food industry as a preservative and flavoring agent, and is also the raw material for the chlor-alkali industry which produces chlorine, hydrogen, and sodium hydroxide. Ammonium nitrate and ammonium sulfate are widely used as agricultural fertilizers, providing nitrogen to plants. Calcium sulfate, known as gypsum, is used in the construction industry to make plaster. Copper sulfate is used as a fungicide in agriculture and as a blue pigment. Understanding salt preparation and properties is essential to many industrial and agricultural processes.	\N	diagram	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
1.2	1	Covalent Bonding	A covalent bond is a chemical bond formed when two atoms share one or more pairs of electrons. Unlike ionic bonding where electrons are transferred, covalent bonding involves the mutual sharing of electrons between atoms. This type of bonding typically occurs between non-metal atoms that have similar electronegativities. The shared electrons are attracted to the nuclei of both atoms, creating a strong bond that holds the atoms together. The shared pair of electrons is called a bonding pair, while electrons that are not shared are called lone pairs or non-bonding pairs.	Covalent bonds can be single, double, or triple depending on the number of electron pairs shared between atoms. A single covalent bond involves the sharing of one pair of electrons, as seen in hydrogen gas H₂ where each hydrogen atom contributes one electron. A double covalent bond involves the sharing of two pairs of electrons, such as in oxygen gas O₂. A triple covalent bond involves the sharing of three pairs of electrons, as in nitrogen gas N₂. Generally, as the number of shared electron pairs increases, the bond becomes shorter and stronger, requiring more energy to break.	The properties of covalent compounds differ significantly from those of ionic compounds. Covalent compounds typically have lower melting and boiling points because the intermolecular forces between molecules are weaker than the ionic bonds in ionic compounds. Most covalent compounds do not conduct electricity, even when dissolved in water, because they do not form ions. Many covalent compounds are soluble in non-polar solvents but insoluble in water. Common examples include water H₂O, methane CH₄, carbon dioxide CO₂, and ammonia NH₃.	The concept of molecular geometry is important in understanding covalent compounds. The arrangement of atoms in a molecule affects its physical and chemical properties. For instance, the bent shape of water molecules contributes to water's unique properties, while the tetrahedral arrangement of carbon in methane influences its reactivity. Lewis structures are often used to represent covalent bonding, showing all valence electrons as dots and bonding pairs as lines between atoms. These diagrams help predict molecular shapes and understand chemical behavior.	\N	animation	/api/media/animations/1.2_animation.mp4	Notice how the two atoms approach each other and their outer electrons begin to interact. Watch as these electrons are not transferred from one atom to another, but rather shared between both atoms. Observe that this sharing creates a mutual attraction, with the shared electrons drawn to both nuclei simultaneously, forming a strong covalent bond.\n\nPay attention to the different types of bonds forming on screen. See how hydrogen gas shows a single bond with just one pair of shared electrons, while oxygen gas demonstrates a double bond with two pairs. Look at nitrogen gas forming an even stronger triple bond with three shared electron pairs. You can see that as more electron pairs are shared, the bond becomes progressively shorter and stronger.\n\nNotice the distinction between bonding pairs—those electrons actively shared between atoms—and lone pairs, which remain unshared on individual atoms. Watch as the Lewis structures appear, representing these valence electrons as dots and bonds as connecting lines.\n\nObserve that covalent compounds behave very differently from ionic compounds. See how molecules like water, methane, and carbon dioxide remain intact rather than separating into ions. Pay attention to the molecular geometry being highlighted—particularly water's bent shape and methane's tetrahedral arrangement. You can see that these spatial arrangements directly influence each compound's unique properties and chemical behavior.	\N	\N	\N	\N	\N	\N	{"markdown": "# Covalent Bonding\\n\\n## Definition\\n### Electron Sharing\\n- Non-metals share electrons\\n- Bonding pairs formed\\n### Lone Pairs\\n- Non-bonding electron pairs\\n- Around atoms\\n\\n## Types of Bonds\\n### Single Bond\\n- One electron pair\\n- Example: H₂ hydrogen\\n### Multiple Bonds\\n- Double: O₂ oxygen\\n- Triple: N₂ nitrogen\\n\\n## Properties\\n### Physical Properties\\n- Low melting points\\n- Weak intermolecular forces\\n### Electrical Properties\\n- Non-conductors of electricity\\n- No ions formed\\n\\n## Common Examples\\n- H₂O water molecule\\n- CH₄ methane gas\\n- CO₂ carbon dioxide\\n- NH₃ ammonia\\n\\n## Exam Tips\\n- Draw Lewis structures\\n- Show dots and lines\\n- Count valence electrons\\n- Predict molecular shapes"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
2.1	2	Structure of the Atom	An atom is the smallest unit of an element that retains the chemical properties of that element. Every atom consists of two main regions: a tiny, dense nucleus at the center and an electron cloud surrounding it. The nucleus contains protons, which carry a positive charge, and neutrons, which have no charge. Electrons, which carry a negative charge, occupy the space outside the nucleus in regions called electron shells or energy levels. The number of protons in the nucleus determines what element the atom is, and this number is called the atomic number.	The three subatomic particles have very different masses and charges. A proton has a relative mass of 1 and a relative charge of plus one. A neutron also has a relative mass of 1 but carries no charge, giving it a relative charge of zero. An electron has a negligible mass approximately 1/1836 of a proton and carries a relative charge of minus one. In a neutral atom, the number of protons always equals the number of electrons, which is why atoms have no overall charge. The mass number of an atom is the total number of protons and neutrons in the nucleus.	Electrons are arranged in shells around the nucleus, and each shell can hold a maximum number of electrons. The first shell closest to the nucleus can hold a maximum of 2 electrons. The second shell can hold a maximum of 8 electrons. The third shell can also hold up to 8 electrons in elements relevant to O-Level chemistry. This arrangement is called the electronic configuration and is written as a series of numbers showing electrons in each shell. For example, sodium with atomic number 11 has the electronic configuration 2,8,1 meaning 2 electrons in the first shell, 8 in the second, and 1 in the third.	The electronic configuration of an atom determines its chemical properties, particularly its reactivity. Atoms with completely filled outer shells, like the noble gases, are very stable and unreactive. Atoms with nearly full or nearly empty outer shells tend to be highly reactive, as they can achieve stability by gaining, losing, or sharing electrons. The outermost electrons are called valence electrons, and it is these electrons that participate in chemical bonding. Understanding the arrangement of electrons is therefore fundamental to understanding why and how elements react with each other.	\N	animation	/api/media/animations/2.1_animation.mp4	Notice how the atom consists of two distinct regions: a tiny, dense nucleus at the center and a surrounding electron cloud. Observe that the nucleus contains two types of particles—the positively charged protons shown in one color and the neutrons with no charge shown in another. Watch as the electrons, carrying negative charges, move in the space outside the nucleus within distinct shells or energy levels.\n\nPay attention to the relative sizes and properties of these subatomic particles. See how both protons and neutrons have a mass of 1, while electrons have a negligible mass of approximately 1/1836 of a proton. Notice that the number of protons determines the element's identity—this is the atomic number you see labeled.\n\nLook at how the electrons arrange themselves in shells around the nucleus. Observe that the first shell, closest to the nucleus, holds a maximum of 2 electrons, while the second and third shells can each hold up to 8 electrons. Watch as we show sodium's electronic configuration of 2,8,1—meaning 2 electrons in the first shell, 8 in the second, and 1 in the third.\n\nNotice how atoms with completely filled outer shells, like the noble gases shown here, remain stable and unreactive. Pay attention to how atoms with nearly empty or nearly full outer shells are highly reactive. See how these outermost valence electrons are the key to understanding chemical bonding and reactivity.	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
1.1	1	Ionic Bonding	An ionic bond is a type of chemical bond formed through the electrostatic attraction between oppositely charged ions. This type of bonding occurs when electrons are transferred from one atom to another, typically from a metal to a non-metal. The metal atom loses electrons to become a positively charged cation, while the non-metal gains these electrons to become a negatively charged anion. The resulting electrostatic force of attraction between these oppositely charged ions holds them together in an ionic compound.	The formation of ionic bonds typically occurs between metals and non-metals due to their difference in electronegativity. Metals such as sodium have low ionization energies and readily lose their valence electrons to achieve a stable electron configuration. Non-metals such as chlorine have high electron affinities and readily gain electrons to complete their outer shell, typically achieving a noble gas configuration. For example, when sodium with one valence electron reacts with chlorine with seven valence electrons, sodium loses one electron to become Na⁺ and chlorine gains one electron to become Cl⁻, both achieving stable octets.	Ionic compounds possess distinctive physical and chemical properties that stem from their ionic bonding. They typically have high melting and boiling points due to the strong electrostatic forces between ions, which require significant energy to overcome. In their solid state, ionic compounds do not conduct electricity because the ions are fixed in position within the crystal lattice. However, when dissolved in water or melted, the ions become mobile and can conduct electricity. Common examples of ionic compounds include sodium chloride NaCl, magnesium oxide MgO, and calcium chloride CaCl₂.	The crystal lattice structure of ionic compounds is another important characteristic. Ions arrange themselves in a regular, repeating three-dimensional pattern to maximize attractive forces and minimize repulsive forces between ions. This arrangement creates a strong, rigid structure. The lattice energy, which is the energy required to separate one mole of an ionic solid into gaseous ions, is a measure of the strength of the ionic bonds. Compounds with smaller ions and higher charges generally have greater lattice energies and consequently higher melting points.	\N	animation	/api/media/animations/1.1_animation.mp4	Notice how the metal atom on the left has electrons in its outer shell that it's ready to give up. Watch as one of these electrons transfers from the metal to the non-metal atom on the right. Observe that as this happens, the metal becomes positively charged—we call this a cation—while the non-metal becomes negatively charged, forming an anion. See how these opposite charges now attract each other, creating the electrostatic force that holds them together.\n\nPay attention to the example of sodium and chlorine appearing on screen. Notice how sodium has just one valence electron while chlorine has seven. Watch as sodium donates its single electron to chlorine. You can see that both atoms now achieve stable octets, resembling the electron configuration of noble gases.\n\nLook at how the ions arrange themselves into a crystal lattice structure—a regular, repeating three-dimensional pattern. Notice that this arrangement maximizes the attractive forces between oppositely charged ions while minimizing repulsion. Observe that in this solid state, the ions are locked in position and cannot move, which is why they don't conduct electricity.\n\nNow watch as we either melt the compound or dissolve it in water. See how the ions become mobile and can now conduct electricity. Pay attention to the high melting point displayed—this reflects the strong electrostatic forces requiring significant energy to overcome. Notice how smaller ions with higher charges create even stronger bonds and higher lattice energies.	آئونی بانڈ ایک قسم کا کیمیائی بانڈ ہے جو مخالف طور پر چارج شدہ آئنز کے مابین الیکٹروسٹیٹک کشش کے ذریعے تشکیل پاتا ہے۔ یہ قسم کا بانڈنگ تب ہوتا ہے جب الیکٹرانوں کو ایک ایٹم سے دوسرے ایٹم میں منتقل کیا جاتا ہے، عام طور پر دھات سے غیر دھات تک۔ دھاتی ایٹم الیکٹران کھو دیتا ہے اور مثبت چارج والا کیشن بن جاتا ہے، جبکہ غیر دھاتی ایٹم ان الیکٹرانوں کو حاصل کرتا ہے اور منفی چارج والا انائن بن جاتا ہے۔ نتیجہ خیز الیکٹروسٹیٹک قوت ان مخالف چارج والے آئنز کے مابین انہیں آئونی مرکب میں ایک ساتھ رکھتی ہے۔	آئونی بانڈز کی تشکیل عام طور پر دھاتوں اور غیر دھاتوں کے مابین ہوتی ہے کیونکہ ان کی الیکٹرونیگٹیوٹی میں فرق ہوتا ہے۔ دھاتوں جیسے سوڈیم میں کم آئنائزیشن انرجیز ہوتی ہے اور وہ آسانی سے اپنے والنس الیکٹران کھو دیتے ہیں تاکہ ایک مستحکم الیکٹران کنفیگریشن حاصل کر سکیں۔ غیر دھاتوں جیسے کلورین میں زیادہ الیکٹران افینٹی ہوتی ہے اور وہ آسانی سے الیکٹران حاصل کر لیتے ہیں تاکہ اپنی بیرونی شیل کو مکمل کر سکیں، عام طور پر ایک نوبل گیس کنفیگریشن حاصل کرتی ہیں۔ مثال کے طور پر، جب ایک والنس الیکٹران والا سوڈیم سات والنس الیکٹران والے کلورین کے ساتھ رد عمل کرتا ہے، تو سوڈیم ایک الیکٹران کھو دیتا ہے اور Na⁺ بن جاتا ہے اور کلورین ایک الیکٹران حاصل کرتا ہے اور Cl⁻ بن جاتا ہے، دونوں مستحکم آکٹیٹ حاصل کرتے ہیں۔	آئونی مرکبات میں ان کی آئونی بانڈنگ سے اخذ ہونے والے واضح طبیعی اور کیمیائی خصوصیات ہوتی ہیں۔ ان میں عام طور پر آئنز کے مابین مضبوط الیکٹروسٹیٹک قوتوں کی وجہ سے زیادہ پگھلنے اور کھولنے کی درجہ حرارت ہوتی ہے، جو ان قوتوں کو دور کرنے کے لیے نمایاں توانائی کی ضرورت ہوتی ہے۔ اپنے ٹھوس حالت میں، آئونی مرکبات بجلی کی conducٹیویٹی نہیں کرتے ہیں کیونکہ آئنز کرسٹل لٹس میں اپنی پوزیشن میں تھے۔ تاہم، جب پانی میں حل ہو جاتے ہیں یا پگھل جاتے ہیں، تو آئنز متحرک ہو جاتے ہیں اور بجلی کی conducٹیویٹی کر سکتے ہیں۔ آئونی مرکبات کے عام مثالوں میں سوڈیم کلورائیڈ NaCl، میگنیشیئم آکسائیڈ MgO، اور کیلشیئم کلورائیڈ CaCl₂ شامل ہیں۔	آئونی مرکبات کی کرسٹل لٹس ساخت ایک اہم خصوصیت ہے۔ آئنز ایک باقاعدہ، تین جہتی نمونے میں اپنے آپ کو ترتیب دیتے ہیں تاکہ آئنز کے مابین کشش ثقل کو زیادہ سے زیادہ کر سکیں اور آئنز کے مابین دفع کرنے والی قوتوں کو کم سے کم کر سکیں۔ یہ انتظام ایک مضبوط، سخت ساخت پیدا کرتا ہے۔ لٹس انرجی، جو ایک آئونی ٹھوس کو گیس آئنز میں الگ کرنے کے لیے درکار انرجی کا ایک پیمانہ ہے، آئونی بانڈز کی طاقت کا ایک پیمانہ ہے۔ چھوٹے آئنز اور زیادہ چارج والے مرکبات عام طور پر زیادہ لٹس انرجی اور اس کے نتیجے میں زیادہ پگھلنے کی درجہ حرارت ہوتی ہے۔	\N	/api/media/audio/1.1_en.mp3	{"markdown": "# Ionic Bonding\\n\\n## Definition and Nature\\n\\n### What is Ionic Bonding\\n- Electrostatic attraction between oppositely charged ions\\n- Chemical bond through electron transfer\\n- Forms between metals and non-metals\\n\\n### Formation Process\\n- Metal loses electrons (oxidation)\\n- Non-metal gains electrons (reduction)\\n- Creates cations and anions\\n- Opposite charges attract strongly\\n\\n## Electron Transfer Mechanism\\n\\n### Metal Atoms Behavior\\n- Low ionization energy\\n- Readily lose valence electrons\\n- Form positively charged cations\\n- Achieve stable electron configuration\\n\\n### Non-metal Atoms Behavior\\n- High electron affinity\\n- Readily gain electrons\\n- Form negatively charged anions\\n- Complete outer electron shell\\n\\n### Noble Gas Configuration\\n- Both ions achieve stable octets\\n- Similar to nearest noble gas\\n- Energetically favorable arrangement\\n- Drives ionic bond formation\\n\\n## Physical Properties\\n\\n### Melting and Boiling Points\\n- Very high melting points\\n- Very high boiling points\\n- Strong electrostatic forces between ions\\n- Requires significant energy to break\\n\\n### Electrical Conductivity\\n- Solid state: does not conduct\\n- Ions fixed in lattice position\\n- Molten state: conducts electricity\\n- Aqueous solution: conducts electricity\\n- Mobile ions carry charge\\n\\n### Mechanical Properties\\n- Hard and rigid structure\\n- Brittle when force applied\\n- Shatters rather than bends\\n- Crystal lattice disruption causes brittleness\\n\\n### Solubility\\n- Many dissolve in water\\n- Polar solvent breaks ionic bonds\\n- Ions surrounded by water molecules\\n- Generally insoluble in non-polar solvents\\n\\n## Crystal Lattice Structure\\n\\n### Arrangement Pattern\\n- Regular three-dimensional repeating pattern\\n- Ions alternate in arrangement\\n- Maximize attractive forces\\n- Minimize repulsive forces\\n\\n### Lattice Energy\\n- Energy to separate ionic solid\\n- Into gaseous ions\\n- Measure of bond strength\\n- Higher values indicate stronger bonds\\n\\n### Factors Affecting Lattice Energy\\n- Smaller ions increase energy\\n- Higher ionic charges increase energy\\n- Greater charge density strengthens bonds\\n- Affects melting point directly\\n\\n## Common Examples\\n\\n### Sodium Chloride (NaCl)\\n- Na loses one electron\\n- Cl gains one electron\\n- Both achieve stable octets\\n- Table salt compound\\n\\n### Magnesium Oxide (MgO)\\n- Mg loses two electrons\\n- O gains two electrons\\n- Forms Mg²⁺ and O²⁻\\n- Very high melting point\\n\\n### Calcium Chloride (CaCl₂)\\n- Ca loses two electrons\\n- Two Cl atoms gain electrons\\n- Forms Ca²⁺ and 2Cl⁻\\n- Used as drying agent\\n\\n### Other Common Compounds\\n- Potassium bromide (KBr)\\n- Aluminum oxide (Al₂O₃)\\n- Sodium oxide (Na₂O)\\n- Lithium fluoride (LiF)\\n\\n## Real-world Applications\\n\\n### Food Industry\\n- Table salt (NaCl) seasoning\\n- Food preservation\\n- Calcium compounds for nutrition\\n- Magnesium supplements\\n\\n### Industrial Uses\\n- Calcium chloride road de-icing\\n- Magnesium oxide refractory materials\\n- Sodium hydroxide in manufacturing\\n- Electrolysis processes\\n\\n### Medical Applications\\n- Saline solutions for IV\\n- Mineral supplements\\n- Dental products with fluoride\\n- Antacids containing carbonates\\n\\n### Daily Life\\n- Toothpaste ingredients\\n- Cleaning products\\n- Fertilizers for agriculture\\n- Water treatment chemicals\\n\\n## Exam Tips\\n\\n### Key Concepts to Remember\\n- Electron transfer not sharing\\n- Metal to non-metal bonding\\n- Opposite charges attract\\n- Noble gas configuration goal\\n\\n### Drawing and Diagrams\\n- Show electron arrangement clearly\\n- Use dots and crosses\\n- Indicate charges on ions\\n- Draw lattice structure accurately\\n\\n### Common Questions\\n- Explain conductivity in different states\\n- Predict formulas from charges\\n- Compare with covalent bonding\\n- Relate structure to properties\\n\\n### Important Calculations\\n- Determine ionic charges correctly\\n- Balance ionic compound formulas\\n- Use charge balance principle\\n- Calculate formula units needed\\n\\n### Typical Mistakes to Avoid\\n- Don't confuse with covalent bonds\\n- Remember ions are mobile when melted\\n- State of matter affects conductivity\\n- Charges must balance in formulas"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
1.4	1	Polar Covalent Bonds	A polar covalent bond is a type of covalent bond in which electrons are shared unequally between two atoms. This unequal sharing occurs when the two atoms have different electronegativities — one atom attracts the shared electrons more strongly than the other. Electronegativity is the ability of an atom to attract bonding electrons toward itself. When the electronegativity difference between two atoms is moderate, typically between 0.4 and 1.7 on the Pauling scale, a polar covalent bond forms. The atom with higher electronegativity develops a partial negative charge denoted delta minus, while the atom with lower electronegativity develops a partial positive charge denoted delta plus.	The polarity of a bond has significant effects on the properties of molecules. In a molecule like hydrogen chloride HCl, chlorine is more electronegative than hydrogen, so the bonding electrons spend more time near the chlorine atom. This creates a dipole moment which is a measure of the separation of positive and negative charges. Dipole moments are represented by arrows pointing from the positive end to the negative end of the bond. The presence of polar bonds can make entire molecules polar if the bond dipoles do not cancel out due to molecular geometry. For example, water H₂O is a polar molecule because it has polar O-H bonds arranged in a bent shape, resulting in a net dipole moment.	Polar covalent bonds play a crucial role in determining molecular behavior and interactions. Molecules with polar bonds often have higher boiling points than non-polar molecules of similar size because the partial charges allow for stronger intermolecular forces, specifically dipole-dipole interactions. Polar molecules tend to dissolve well in polar solvents like water, following the principle that like dissolves like. Understanding bond polarity is essential in organic chemistry, biochemistry, and materials science, as it affects everything from protein folding to the properties of polymers. Common examples of molecules with polar covalent bonds include water H₂O, ammonia NH₃, and hydrogen fluoride HF.	\N	\N	animation	/api/media/animations/1.4_animation.mp4	Notice how the two atoms in this bond are sharing electrons, but observe that the electron cloud is not evenly distributed between them. Watch as the electrons spend more time closer to one atom than the other—this is what happens when atoms have different electronegativities. Pay attention to the electronegativity values shown: when the difference falls between 0.4 and 1.7 on the Pauling scale, you can see that a polar covalent bond forms.\n\nLook at how the atom with higher electronegativity develops a partial negative charge, marked as δ−, while the other atom shows a partial positive charge, marked as δ+. In this hydrogen chloride molecule, notice how the electrons are pulled toward the chlorine atom because it's more electronegative than hydrogen. See how this creates a dipole moment, represented by the arrow pointing from the positive to the negative end.\n\nObserve that in the water molecule, the two O-H bonds are both polar, and because of the bent molecular shape, watch as these individual bond dipoles combine into a net dipole moment for the entire molecule. Notice how molecules with polar bonds tend to have higher boiling points compared to similar-sized nonpolar molecules. You can see that this occurs because the partial charges enable stronger intermolecular forces through dipole-dipole interactions. Pay attention to how polar molecules like water, ammonia, and hydrogen fluoride interact preferentially with other polar substances.	پولر کووالنٹ بانڈ ایک قسم کا کووالنٹ بانڈ ہے جس میں الیکٹران دو ایٹم کے درمیان غیر مساوی طور پر شیئر کیے جاتے ہیں۔ یہ غیر مساوی شیئرنگ اس وقت ہوتی ہے جب دو ایٹم مختلف الیکٹرونیگٹیویٹی کے حامل ہوتے ہیں — ایک ایٹم مشترکہ الیکٹران کو دوسرے کے مقابلے میں زیادہ مضبوطی سے کھینچتا ہے۔ الیکٹرونیگٹیویٹی ایک ایٹم کی وہ صلاحیت ہے جو بانڈنگ الیکٹران کو اپنی طرف کھینچنے میں مدد کرتی ہے۔ جب دو ایٹم کے درمیان الیکٹرونیگٹیویٹی کا فرق معتدل ہوتا ہے، جو عام طور پر پالنگ سکیل پر 0.4 سے 1.7 کے درمیان ہوتا ہے، تو ایک پولر کووالنٹ بانڈ تشکیل پاتا ہے۔ زیادہ الیکٹرونیگٹیویٹی والا ایٹم ایک جزوی منفی چارج تیار کرتا ہے جسے ڈیلٹا منیس کے نام سے ظاہر کیا جاتا ہے، جبکہ کم الیکٹرونیگٹیویٹی والا ایٹم ایک جزوی مثبت چارج تیار کرتا ہے جسے ڈیلٹا پلس کے نام سے ظاہر کیا جاتا ہے۔	بانڈ کی پولرٹی کا مالیکیول کی خصوصیات پر نمایاں اثر پڑتا ہے۔ ہائیڈروجن کلورائیڈ HCl جیسے مالیکیول میں، کلورین ہائیڈروجن کے مقابلے میں زیادہ الیکٹرونیگٹیویٹی کا حامل ہوتا ہے، اس لیے بانڈنگ الیکٹران زیادہ تر وقت کلورین ایٹم کے قریب گزارتے ہیں۔ اس سے ڈپول مومنٹ تیار ہوتا ہے جو مثبت اور منفی چارجز کی علیحدگی کی پیمائش ہے۔ ڈپول مومنٹ کو بانڈ کے مثبت سے منفی سرے کی طرف اشارہ کرنے والے تीर کے ذریعے ظاہر کیا جاتا ہے۔ پولر بانڈز کی موجودگی مکمل مالیکیول کو پولر بنا سکتی ہے اگر بانڈ ڈپولز مالیکیولر جیومیٹری کی وجہ سے منسوخ نہیں ہوتے ہیں۔ مثال کے طور پر، پانی H₂O ایک پولر مالیکیول ہے کیونکہ اس میں پولر O-H بانڈز ہیں جو ایک مڑے ہوئے شکل میں ترتیب دیے گئے ہیں، جس کے نتیجے میں ایک نیٹ ڈپول مومنٹ بنتا ہے۔	پولر کووالنٹ بانڈز مالیکیولر رویے اور انٹرایکشنز کو متعین کرنے میں اہم کردار ادا کرتے ہیں۔ پولر بانڈز والے مالیکیول اکثر غیر پولر مالیکیولز کے مقابلے میں زیادہ ابال نقطہ رکھتے ہیں کیونکہ جزوی چارجز انٹر مالیکیولر فورسز کے لیے امکانات پیدا کرتے ہیں، خاص طور پر ڈپول-ڈپول انٹرایکشنز۔ پولر مالیکیول پولر حل کرنے والے جیسے پانی میں اچھی طرح حل ہوتے ہیں، جو اس اصول کی پیروی کرتے ہیں کہ ایک جیسا دوسرے جیسے کو حل کرتا ہے۔ بانڈ پولرٹی کو سمجھنا آργانک کیمسٹری، بائیو کیمسٹری، اور میٹریل سائنس میں لازمی ہے، کیونکہ یہ پروٹین فولڈنگ سے لے کر پولی مرز کی خصوصیات تک ہر چیز کو متاثر کرتا ہے۔ پولر کووالنٹ بانڈز والے مالیکیول کے عام مثالوں میں پانی H₂O، امونیا NH₃، اور ہائیڈروجن فلورائیڈ HF شامل ہیں۔	\N	\N	/api/media/audio/1.4_en.mp3	{"markdown": "# Polar Covalent Bonds\\n\\n## Definition\\n### Unequal Electron Sharing\\n- Different electronegativity values\\n- Partial charge formation\\n### Electronegativity Difference\\n- Range 0.4-1.7\\n- Pauling scale measurement\\n\\n## Key Features\\n### Partial Charges\\n- δ+ on less electronegative\\n- δ- on more electronegative\\n### Dipole Moment\\n- Charge separation measure\\n- Arrow points negative\\n\\n## Properties\\n### Molecular Polarity\\n- Bond dipoles arrangement\\n- Geometry affects polarity\\n### Intermolecular Forces\\n- Dipole-dipole interactions\\n- Higher boiling points\\n\\n## Examples\\n- Water H₂O\\n- Ammonia NH₃\\n- Hydrogen chloride HCl\\n- Hydrogen fluoride HF\\n\\n## Exam Tips\\n- Check electronegativity difference\\n- Draw dipole arrows\\n- Consider molecular shape\\n- Like dissolves like"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
1.5	1	Hydrogen Bonding	A hydrogen bond is a special type of intermolecular force that occurs when a hydrogen atom bonded to a highly electronegative atom such as nitrogen, oxygen, or fluorine is attracted to another electronegative atom in a nearby molecule. Despite its name, a hydrogen bond is not a true chemical bond like ionic or covalent bonds, but rather a strong dipole-dipole attraction. The hydrogen atom, being small and having its electron pulled toward the electronegative atom it is bonded to, develops a significant partial positive charge. This partially positive hydrogen is then attracted to the lone pair of electrons on a nearby electronegative atom, creating the hydrogen bond.	Hydrogen bonding is responsible for many unique and important properties of substances, particularly water. Water's unusually high boiling point for such a small molecule is due to extensive hydrogen bonding between water molecules. Each water molecule can form up to four hydrogen bonds — two through its hydrogen atoms and two through the lone pairs on its oxygen atom. This network of hydrogen bonds also explains why ice is less dense than liquid water. When water freezes, hydrogen bonds arrange the molecules in a hexagonal lattice with more space between molecules than in the liquid state, causing ice to float. This property is crucial for aquatic life, as it prevents bodies of water from freezing solid from the bottom up.	Hydrogen bonding plays a vital role in biological systems. The structure and function of proteins and nucleic acids depend heavily on hydrogen bonds. In DNA, hydrogen bonds between complementary base pairs hold the two strands of the double helix together. These bonds are strong enough to maintain the DNA structure but weak enough to allow the strands to separate during replication and transcription. In proteins, hydrogen bonds help stabilize secondary structures like alpha helices and beta sheets. Although hydrogen bonds are weaker than covalent or ionic bonds, typically about 5 percent the strength of a covalent bond, they are significantly stronger than other intermolecular forces.	\N	\N	diagram	/api/media/diagrams/1.5_diagram.png	Notice how the hydrogen atom bonded to the oxygen develops a partial positive charge as its electron is pulled toward the highly electronegative oxygen atom. Watch as this partially positive hydrogen is attracted to the lone pair of electrons on a nearby oxygen atom in another molecule. Observe that this attraction, called a hydrogen bond, appears as a dotted line between the molecules—it's not a true chemical bond like the covalent bonds within each molecule, but rather a strong dipole-dipole attraction.\n\nPay attention to how each water molecule can participate in four hydrogen bonds simultaneously. See how two bonds form through the hydrogen atoms, while two more form through the oxygen's lone pairs. Watch as these hydrogen bonds create an extensive network throughout the liquid. This network is why water has such an unusually high boiling point for its small size.\n\nNow observe what happens when water freezes. Notice how the hydrogen bonds arrange the molecules into a hexagonal lattice structure. See how this arrangement actually spaces the molecules farther apart than in liquid water, making ice less dense. Look at how the ice floats as a result—a crucial property for aquatic ecosystems.\n\nFinally, examine how hydrogen bonds appear in biological molecules. In this DNA model, notice the hydrogen bonds connecting the base pairs between the two strands. Observe that these bonds are strong enough to hold the double helix together, yet weak enough to separate during replication.	ہائیڈروجن بانڈ ایک خاص قسم کا بین الatomic قوت ہے جو اس وقت پیش آتا ہے جب ہائیڈروجن ایٹم جو نائٹروجن، آکسیجن، یا فلورین جیسے اعلیٰ برقی منفیت والے ایٹم سے جڑا ہوتا ہے، ایک قریب کی مالیکول میں دوسرے برقی منفیت والے ایٹم کی طرف کشش کرتا ہے۔ اس کے نام کے باوجود، ہائیڈروجن بانڈ آئونک یا کووالنٹ بانڈز کی طرح ایک سچا کیمیائی بانڈ نہیں ہے، بلکہ ایک مضبوط ڈپول-ڈپول کشش ہے۔ ہائیڈروجن ایٹم، جو چھوٹا ہے اور اس کا الیکٹران برقی منفیت والے ایٹم کی طرف کھینچا جاتا ہے جس سے یہ جڑا ہوا ہے، ایک نمایاں جزوی مثبت چارج تیار کرتا ہے۔ یہ جزوی مثبت ہائیڈروجن پھر قریب کی برقی منفیت والے ایٹم پر الون جوڑے کے الیکٹرانز کی طرف کشش کرتا ہے، جو ہائیڈروجن بانڈ بناتا ہے۔	ہائیڈروجن بانڈنگ مادوں کی بہت ساری انوکھری اور اہم خصوصیات کا ذمہ دار ہے، خاص طور پر پانی۔ پانی کا غیر معمولی طور پر بلند کھولنے کا نقطہ ایک چھوٹی سی مالیکول کے لیے ہائیڈروجن بانڈنگ کے وسیع نیٹ ورک کی وجہ سے ہے۔ ہر پانی کی مالیکول چار ہائیڈروجن بانڈز بنا سکتی ہے - دو اپنے ہائیڈروجن ایٹموز کے ذریعے اور دو اپنے آکسیجن ایٹم پر الون جوڑے کے ذریعے۔ ہائیڈروجن بانڈز کا یہ نیٹ ورک یہ بھی واضح کرتا ہے کہ برف کیوں پانی کے مائع حالت سے کم گھنی ہے۔ جب پانی جم جاتا ہے، تو ہائیڈروجن بانڈز مالیکولز کو ایک ہیکساگونل لٹس میں ترتیب دیتے ہیں جس میں مالیکولز کے درمیان مائع حالت کے مقابلے میں زیادہ خالی جگہ ہوتی ہے، جس کی وجہ سے برف تیرتی ہے۔ یہ خصوصیت آبی حیات کے لیے نہایت اہم ہے، کیونکہ یہ پانی کے ذخائر کو نیچے سے اوپر کی طرف جمنے سے روکتی ہے۔	ہائیڈروجن بانڈنگ حیاتیاتی نظاموں میں اہم کردار ادا کرتی ہے۔ پروٹینز اور نائکلیک ایسڈز کی ساخت اور کام ہائیڈروجن بانڈز پر بہت زیادہ انحصار کرتے ہیں۔ ڈی این اے میں، ہائیڈروجن بانڈز ڈبل ہیلکس کے دو تانے بانڈز کو ایک ساتھ رکھتے ہیں۔ یہ بانڈز ڈی این اے کی ساخت کو برقرار رکھنے کے لیے کافی مضبوط ہیں لیکن انہیں جماعی اور نقل کے دوران تانے بانڈز کو الگ کرنے کی اجازت دینے کے لیے کمزور ہیں۔ پروٹینز میں، ہائیڈروجن بانڈز سیکنڈری ساختوں جیسے الفا ہیلکس اور بیٹا شیٹس کو مستحکم کرنے میں مدد کرتے ہیں۔ اگرچہ ہائیڈروجن بانڈز کووالنٹ یا آئونک بانڈز کے مقابلے میں کمزور ہوتے ہیں، عام طور پر کووالنٹ بانڈ کی طاقت کا تقریباً 5 فیصد، وہ دیگر بین الatomic قوتوں کے مقابلے میں کافی مضبوط ہیں۔	\N	\N	/api/media/audio/1.5_en.mp3	{"markdown": "# Hydrogen Bonding\\n\\n## Definition\\n### Nature of Bond\\n- Strong dipole-dipole attraction\\n- Not true chemical bond\\n### Requirements\\n- H bonded to N/O/F\\n- Nearby electronegative atom\\n\\n## Key Features\\n### Hydrogen Characteristics\\n- Small atomic size\\n- Significant partial positive charge\\n### Electronegative Atom Role\\n- Attracts hydrogen\\n- Has lone electron pairs\\n\\n## Properties of Water\\n### High Boiling Point\\n- Extensive hydrogen bonding\\n- Each molecule forms four bonds\\n### Ice Less Dense\\n- Hexagonal lattice structure\\n- Ice floats on water\\n\\n## Biological Importance\\n### DNA Structure\\n- Holds complementary base pairs\\n- Allows strand separation\\n### Protein Structure\\n- Stabilizes alpha helices\\n- Stabilizes beta sheets\\n\\n## Exam Tips\\n- Compare bond strengths\\n- Draw hydrogen bond diagrams"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.5	4	Electrolysis	Electrolysis is the process of decomposing an ionic compound by passing an electric current through it when it is either molten or dissolved in water. The compound being electrolyzed is called the electrolyte, and it must contain mobile ions that can carry the electric current. In the solid state, ionic compounds cannot conduct electricity because their ions are in fixed positions. However, when melted or dissolved, the ions become free to move and can migrate toward the oppositely charged electrodes. The two electrodes are the cathode which is connected to the negative terminal of the power supply and the anode which is connected to the positive terminal.	During electrolysis, positive ions called cations migrate toward the negative cathode and negative ions called anions migrate toward the positive anode. At the cathode, cations gain electrons in a reduction reaction to form neutral atoms or molecules. At the anode, anions lose electrons in an oxidation reaction to form neutral atoms or molecules. The products of electrolysis depend on the electrolyte being used and the electrode material. For example, when molten lead bromide is electrolyzed, lead metal is deposited at the cathode and bromine gas is released at the anode.	When aqueous solutions are electrolyzed rather than molten salts, the presence of water complicates the products because water itself can be oxidized or reduced. In the electrolysis of dilute sulfuric acid, hydrogen gas is produced at the cathode as hydrogen ions from water are reduced, and oxygen gas is produced at the anode as water molecules are oxidized. In the electrolysis of concentrated sodium chloride solution called brine, hydrogen gas is produced at the cathode, chlorine gas is produced at the anode, and sodium hydroxide solution remains in the electrolyte. This chlor-alkali process is extremely important industrially.	Electrolysis has numerous important industrial applications. Aluminum is extracted from molten aluminum oxide by electrolysis because aluminum is too reactive to be extracted by reduction with carbon. Copper is purified by electrolysis using a pure copper cathode and an impure copper anode in copper sulfate solution — copper dissolves from the anode and pure copper deposits on the cathode. Electroplating uses electrolysis to coat objects with a thin layer of metal for decorative purposes or to prevent corrosion. For example, steel cutlery is often silver-plated or chromium-plated using electrolysis. The quantity of product formed during electrolysis is governed by Faraday's laws of electrolysis.	\N	animation	/api/media/animations/4.5_animation.mp4	Notice how the ionic compound in its solid state has ions locked in fixed positions, unable to conduct electricity. Watch as heat melts the compound or it dissolves in water—observe that the ions now become mobile and free to move throughout the liquid. See how the two electrodes are positioned in the electrolyte: the cathode connects to the negative terminal while the anode connects to the positive terminal of the power supply.\n\nPay attention to the movement of ions as the current flows. Notice how the positive cations migrate toward the negative cathode, while the negative anions move toward the positive anode. Watch what happens at each electrode: at the cathode, cations gain electrons through reduction, forming neutral atoms or molecules. At the anode, observe that anions lose electrons through oxidation, also producing neutral substances.\n\nLook at the example of molten lead bromide—see how silvery lead metal deposits at the cathode while reddish-brown bromine gas bubbles up at the anode. When aqueous solutions are used instead, notice how water itself can participate in the reactions. Observe the electrolysis of dilute sulfuric acid producing hydrogen gas at the cathode and oxygen gas at the anode. In concentrated sodium chloride solution, watch as hydrogen and chlorine gases form while sodium hydroxide remains in solution.\n\nFinally, notice the important industrial applications: aluminum extraction from molten oxide, copper purification, and electroplating for decoration or corrosion protection.	الیکٹرونک کیمیاء کا عمل ایک آئونی مرکب کو الیکٹرک کرنٹ کے ذریعے اس وقت توڑنے کا عمل ہے جب وہ پگھلا ہوا ہو یا پانی میں حل ہو۔ الیکٹرونک کیا جانے والا مرکب الیکٹرولائٹ کہلاتا ہے، اور اس میں قابل نقل ایونز ہونے چاہئیں جو الیکٹرک کرنٹ کو لے جا سکیں۔ ٹھوس حالت میں، آئونی مرکبات بجلی کو موصل نہیں کر سکتے کیونکہ ان کے آئنز固定 پوزیشنوں پر ہوتے ہیں۔ تاہم، جب پگھلا دیا جائے یا حل ہو جائے، تو آئنز آزاد ہو جاتے ہیں اور مخالف چارج والے الیکٹروڈز کی طرف ہجرت کر سکتے ہیں۔ دونوں الیکٹروڈز کیتھوڈ ہوتے ہیں جو پاور سپلائی کے منفی ٹرمنل سے منسلک ہوتے ہیں اور اینوڈ ہوتے ہیں جو پاور سپلائی کے مثبت ٹرمنل سے منسلک ہوتے ہیں۔	الیکٹرونک کے دوران، مثبت آئنز جیسے کیشنز منفی کیتھوڈ کی طرف ہجرت کرتے ہیں اور منفی آئنز جیسے اینیونز مثبت اینوڈ کی طرف ہجرت کرتے ہیں۔ کیتھوڈ پر، کیشنز الیکٹرانوں کو ایک ریڈکشن ری ایکشن میں حاصل کرتے ہیں تاکہ غیر جانبدار ایٹم یا مالیکیول بن سکیں۔ اینوڈ پر، اینیونز الیکٹرانوں کو ایک آکسیڈیشن ری ایکشن میں کھو دیتے ہیں تاکہ غیر جانبدار ایٹم یا مالیکیول بن سکیں۔ الیکٹرونک کے مصنوعات الیکٹرولائٹ کے استعمال اور الیکٹروڈ مواد پر منحصر ہوتی ہیں۔ مثال کے طور پر، جب پگھلا ہوا لیڈ برومائیڈ الیکٹرولائز ہوتا ہے، تو لیڈ دھات کیتھوڈ پر جمع ہوتی ہے اور برومائن گیس اینوڈ پر ریلیز ہوتی ہے۔	جب پانی کے آبی حل الیکٹرولائز ہوتے ہیں، پانی کی موجودگی مصنوعات کو پیچیدہ बनاتی ہے کیونکہ پانی خود آکسیڈائز ہو سکتا ہے یا ریڈیوس ہو سکتا ہے۔ ڈلٹ سلفیورک ایسڈ کی الیکٹرونک میں، ہائیڈروجن گیس کیتھوڈ پر پیدا ہوتی ہے جب ہائیڈروجن آئنز پانی سے ریڈیوس ہوتے ہیں، اور آکسیجن گیس اینوڈ پر پیدا ہوتی ہے جب پانی کے مالیکیول آکسیڈائز ہوتے ہیں۔ سΟΔیئم کلورائیڈ کے濃حل حل، جسے برائن کہتے ہیں، کی الیکٹرونک میں، ہائیڈروجن گیس کیتھوڈ پر پیدا ہوتی ہے، کلورین گیس اینوڈ پر پیدا ہوتی ہے، اور سودیئم ہائیڈروآکسائیڈ کا حل الیکٹرولائٹ میں رہتا ہے۔ یہ کلور-الکالی پروسس صنعتی طور پر بہت اہم ہے۔	الیکٹرونک کے بہت سے اہم صنعتی اطلاق ہیں۔ الومینیم کو الومینیم آکسائیڈ کے پگھلے ہوئے حل سے الیکٹرونک کے ذریعے نکالا جاتا ہے کیونکہ الومینیم بہت ری ایکٹو ہے اور کاربن کے ساتھ ریڈکشن کے ذریعے نکالا نہیں جا سکتا۔ کاپر کو کاپر سلفیٹ کے حل میں خالص کاپر کیتھوڈ اور غیر خالص کاپر اینوڈ کے ساتھ الیکٹرونک کے ذریعے صاف کیا جاتا ہے — کاپر اینوڈ سے حل ہوتا ہے اور خالص کاپر کیتھوڈ پر جمع ہوتا ہے۔ الیکٹروپلیٹنگ الیکٹرونک کے ذریعے دھات کا پتلا تہہ کرکے اشیاء کو سجاتی ہے یا خرابی سے بچاتی ہے۔ مثال کے طور پر، سٹیل کٹلری اکثر الیکٹرونک کے ذریعے چاندی یا کرومیئم سے ڈھکی ہوتی ہے۔ الیکٹرونک کے دوران بننے والے مصنوعات کی مقدار فاراڈے کے الیکٹرونک کے قوانین کے ذریعے کنٹرول کی جاتی ہے۔	\N	/api/media/audio/4.5_en.mp3	{"markdown": "# Electrolysis\\n\\n## Definition\\n### Process Requirements\\n- Decomposing ionic compounds\\n- Passing electric current\\n### Electrolyte Conditions\\n- Molten or aqueous\\n- Mobile ions present\\n\\n## Key Components\\n### Electrodes\\n- Cathode: negative terminal\\n- Anode: positive terminal\\n### Ion Movement\\n- Cations to cathode\\n- Anions to anode\\n\\n## Reactions at Electrodes\\n### Cathode Process\\n- Reduction occurs\\n- Cations gain electrons\\n### Anode Process\\n- Oxidation occurs\\n- Anions lose electrons\\n\\n## Important Examples\\n### Molten Electrolytes\\n- Lead bromide electrolysis\\n- Aluminum oxide extraction\\n### Aqueous Solutions\\n- Dilute sulfuric acid\\n- Brine chlor-alkali process\\n\\n## Industrial Applications\\n### Metal Extraction\\n- Aluminum from ore\\n- Copper purification\\n### Electroplating\\n- Decorative metal coating\\n- Corrosion prevention"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
3.1	3	The Three States of Matter	Matter exists in three common states: solid, liquid, and gas. These states differ in the arrangement, movement, and energy of the particles they contain. In a solid, particles are tightly packed together in a regular, ordered arrangement. The particles vibrate about fixed positions but cannot move freely from place to place. This gives solids a definite shape and a definite volume. Solids are generally incompressible because the particles are already as close together as they can be.	In a liquid, particles are close together but not in a fixed arrangement. The particles can move past each other, which allows liquids to flow and take the shape of their container. However, the particles in a liquid are still close enough together that liquids have a definite volume and are nearly incompressible. The forces between particles in a liquid are strong enough to keep them from flying apart but not strong enough to hold them in fixed positions. This intermediate state gives liquids their unique flowing properties.	In a gas, particles are spread far apart with large spaces between them. Gas particles move rapidly and randomly in all directions, frequently colliding with each other and with the walls of their container. Gases have neither a definite shape nor a definite volume — they expand to fill whatever container they are placed in. Gases are highly compressible because of the large spaces between particles. The particles in a gas have much higher kinetic energy than in solids or liquids, which is why gases exert pressure on the walls of their containers.	The kinetic particle theory explains the properties of the three states of matter. According to this theory, all matter is made up of tiny particles that are in constant motion. The higher the temperature, the greater the kinetic energy of the particles and the faster they move. The state of a substance depends on the balance between the kinetic energy of its particles and the strength of the forces between those particles. When kinetic energy overcomes intermolecular forces, a substance changes from solid to liquid to gas. This theory successfully explains properties like diffusion, pressure, and changes of state.	\N	animation	/api/media/animations/3.1_animation.mp4	Notice how the particles in the solid are tightly packed together in a regular, ordered pattern. Watch as they vibrate in place but remain locked in their fixed positions—this is why solids maintain both a definite shape and volume. Observe that the particles cannot be pushed closer together, making solids incompressible.\n\nNow look at the liquid state. See how the particles are still close together, but they're no longer locked in fixed positions. Pay attention to how they slide and move past one another—this is what allows liquids to flow and take the shape of their container. Notice, however, that the particles remain close enough to give liquids a definite volume, even though their shape changes.\n\nObserve the dramatic difference in the gas state. See how the particles are spread far apart with large empty spaces between them. Watch as they move rapidly and randomly in all directions, constantly colliding with each other and the container walls. Notice how the gas expands to fill the entire container—gases have neither definite shape nor definite volume. Pay attention to those large spaces between particles; this is why gases are highly compressible.\n\nLook closely at how particle motion increases as we move from solid to liquid to gas. You can see that higher kinetic energy allows particles to overcome the forces holding them together, explaining why substances change state when heated.	مادہ تین عام حالتوں میں موجود ہوتا ہے: ٹھوس، مائع، اور گیس۔ یہ حالتیں ان کی ساخت، حرکت، اور توانائی میں فرق ہوتی ہیں۔ ایک ٹھوس میں، ذرے ایک باقاعدہ، منظم ترتیب میں بہت قریب سے پکے ہوئے ہوتے ہیں۔ ذرے اپنی متعینہ مقامات کے ارد گرد لہرتے ہیں لیکن آزادانہ طور پر ایک جگہ سے دوسری جگہ پر نہیں جا سکتے۔ یہ ٹھوسوں کو ایک متعینہ شکل اور ایک متعینہ حجم دیتا ہے۔ ٹھوس عموماً غیر دباؤ پزیر ہوتے ہیں کیونکہ ذرے پہلے ہی ایک دوسرے کے قریب سے پکے ہوئے ہوتے ہیں جتنا کہ وہ ہو سکتے ہیں۔	ایک مائع میں، ذرے قریب ہوتے ہیں لیکن ایک متعینہ ترتیب میں نہیں ہوتے۔ ذرے ایک دوسرے کے ارد گرد حرکت کر سکتے ہیں، جو مائع کو بہنے اور اپنے کنٹینر کی شکل لینے کی اجازت دیتا ہے۔ تاہم، مائع میں ذرے اب بھی ایک دوسرے کے قریب ہوتے ہیں کہ مائع کا ایک متعینہ حجم ہوتا ہے اور تقریباً غیر دباؤ پزیر ہوتا ہے۔ مائع میں ذروں کے درمیان قوتیں انہیں الگ ہونے سے روکنے کے لیے کافی مضبوط ہوتی ہیں لیکن انہیں متعینہ مقامات پر رکھنے کے لیے کافی مضبوط نہیں ہوتی۔ یہ درمیانی حالت مائع کو ان کی منفرد بہاؤ کی خصوصیات دیتی ہے۔	ایک گیس میں، ذرے بہت دور سے پھیلے ہوئے ہوتے ہیں جس کے درمیان بڑی خالی جگہیں ہوتی ہیں۔ گیس کے ذرے تیزی سے اور بے ترتیب طور پر ہر سمت میں حرکت کرتے ہیں، اکثر ایک دوسرے سے اور اپنے کنٹینر کی دیواروں سے ٹکراتے ہیں۔ گیسوں کی کوئی متعینہ شکل نہیں ہوتی ہے اور نہ ہی کوئی متعینہ حجم ہوتا ہے — وہ ہر کنٹینر کو بھرنے کے لیے پھیل جاتے ہیں جس میں وہ رکھے جاتے ہیں۔ گیسوں میں ذروں کے درمیان بڑی خالی جگہوں کی وجہ سے وہ بہت دباؤ پزیر ہوتی ہیں۔ گیس میں ذروں کی جنبش توانائی ٹھوسوں یا مائعوں میں ذروں کی جنبش توانائی سے کہیں زیادہ ہوتی ہے، جو گیسوں کو اپنے کنٹینرز کی دیواروں پر دباؤ ڈالنے کی وجہ ہے۔	جنبش ذرہ نظریہ مادہ کی تینوں حالتوں کی خصوصیات کی وضاحت کرتا ہے۔ اس نظریے کے مطابق، تمام مادہ چھوٹے چھوٹے ذروں سے بنا ہوتا ہے جو ہمیشہ حرکت میں ہوتے ہیں۔ جتنا زیادہ درجہ حرارت ہوتا ہے، ذروں کی جنبش توانائی اتنی ہی زیادہ ہوتی ہے اور وہ اتنی ہی تیزی سے حرکت کرتے ہیں۔ مادہ کی حالت ان کی جنبش توانائی اور ان ذروں کے درمیان قوتوں کی طاقت کے درمیان توازن پر منحصر ہوتی ہے۔ جب جنبش توانائی بین الجزیوی قوتیں کو مات دیتی ہے، تو مادہ ٹھوس سے مائع اور پھر گیس میں تبدیل ہو جاتا ہے۔ یہ نظریہ کامیابی سے خصوصیات جیسے انتشار، دباؤ، اور حالت کی تبدیلی کی وضاحت کرتا ہے۔	\N	/api/media/audio/3.1_en.mp3	{"markdown": "# Three States of Matter\\n\\n## Solid State\\n### Particle Arrangement\\n- Tightly packed, regular\\n- Fixed positions only\\n### Key Properties\\n- Definite shape, volume\\n- Incompressible structure\\n\\n## Liquid State\\n### Particle Arrangement\\n- Close but irregular\\n- Move past each other\\n### Key Properties\\n- Definite volume only\\n- Takes container shape\\n\\n## Gas State\\n### Particle Arrangement\\n- Widely spaced apart\\n- Random rapid movement\\n### Key Properties\\n- No definite shape/volume\\n- Highly compressible\\n\\n## Kinetic Particle Theory\\n### Main Concept\\n- Particles in constant motion\\n- Temperature affects speed\\n### Energy and Forces\\n- Kinetic energy vs forces\\n- Explains state changes\\n\\n## Exam Tips\\n- Compare three states\\n- Link properties to arrangement"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
2.3	2	Electronic Configuration	Electronic configuration describes the arrangement of electrons in the shells or energy levels of an atom. Electrons occupy shells in order of increasing energy, filling the innermost shell first before moving to the next. The first shell can hold a maximum of 2 electrons, the second shell can hold up to 8 electrons, and the third shell can hold up to 8 electrons for elements in the first three periods of the periodic table. This filling pattern follows specific rules and determines the chemical behavior of each element.	The electronic configurations of the first twenty elements follow a clear pattern. Hydrogen has 1 electron giving configuration 1. Helium has 2 electrons giving configuration 2. Lithium has 3 electrons giving configuration 2,1. Neon has 10 electrons giving configuration 2,8. Sodium has 11 electrons giving configuration 2,8,1. Argon has 18 electrons giving configuration 2,8,8. Calcium has 20 electrons giving configuration 2,8,8,2. Elements in the same group of the periodic table have the same number of valence electrons and therefore similar chemical properties.	The relationship between electronic configuration and the periodic table is fundamental. The period number of an element corresponds to the number of electron shells it has. Group 1 elements all have one electron in their outermost shell, group 2 elements have two, and so on across the table. Group 0 or Group 18 elements, the noble gases, have completely filled outer shells which explains their chemical inertness. The number of valence electrons determines how an element will react — whether it will lose electrons like metals, gain electrons like non-metals, or share electrons in covalent bonding.	Electronic configuration is directly related to the formation of ions. When a metal atom loses electrons to form a positive ion, it loses electrons from its outermost shell. For example, sodium 2,8,1 loses one electron to form Na⁺ with configuration 2,8, which is the same as neon. When a non-metal atom gains electrons to form a negative ion, the electrons are added to the outermost shell. For example, chlorine 2,8,7 gains one electron to form Cl⁻ with configuration 2,8,8, which is the same as argon. This tendency to achieve noble gas configuration drives much of chemical reactivity.	\N	animation	\N	\N	الیکٹرانک ترتیب ایٹم کے شیلز یا توانائی کے درجوں میں الیکٹرانوں کے انتظام کی وضاحت کرتی ہے۔ الیکٹران توانائی میں بڑھتے ہوئے شیلز کو پُر کرتے ہیں، اندرونی شیل کو پہلے پُر کرتے ہیں اور پھر اگلے شیل میں جاتے ہیں۔ پہلا شیل 2 الیکٹرانوں کی زیادہ سے زیادہ گنجائش رکھتا ہے، دوسرا شیل 8 الیکٹرانوں کی گنجائش رکھتا ہے، اور تیسرا شیل مینڈیلیف کے طاقم کے پہلے تین ادوار کے عناصر کے لیے 8 الیکٹرانوں کی گنجائش رکھتا ہے۔ یہ پُر ہونے کا نمونہ خاص قواعد کا پیروکار ہے اور ہر عنصر کے کیمیائی رویے کو متعین کرتا ہے۔	پہلے بیس عناصر کی الیکٹرانک ترتیب میں واضح نمونہ نظر آتا ہے۔ ہائیڈروجن میں 1 الیکٹران ہوتا ہے جس کی ترتیب 1 ہوتی ہے۔ ہیلیم میں 2 الیکٹران ہوتے ہیں جس کی ترتیب 2 ہوتی ہے۔ لیتھیئم میں 3 الیکٹران ہوتے ہیں جس کی ترتیب 2,1 ہوتی ہے۔ نیون میں 10 الیکٹران ہوتے ہیں جس کی ترتیب 2,8 ہوتی ہے۔ سوڈیئم میں 11 الیکٹران ہوتے ہیں جس کی ترتیب 2,8,1 ہوتی ہے۔ آرگون میں 18 الیکٹران ہوتے ہیں جس کی ترتیب 2,8,8 ہوتی ہے۔ کیلشیئم میں 20 الیکٹران ہوتے ہیں جس کی ترتیب 2,8,8,2 ہوتی ہے۔ مینڈیلیف کے طاقم کے ایک ہی گروہ کے عناصر میں بالکل ایک جیسی تعداد میں والینس الیکٹران ہوتے ہیں اور اس لیے ایک جیسی کیمیائی خصوصیات ہوتی ہیں۔	الیکٹرانک ترتیب اور مینڈیلیف کے طاقم کے درمیان تعلق بنیادی ہے۔ عنصر کا دور نمبر اس کے الیکٹران شیلز کی تعداد کے برابر ہوتا ہے۔ گروہ 1 کے عناصر کے بیرونی شیل میں 1 الیکٹران ہوتا ہے، گروہ 2 کے عناصر کے بیرونی شیل میں 2 الیکٹران ہوتے ہیں اور اسی طرح طاقم بھر میں۔ گروہ 0 یا گروہ 18، نوبل گیسوں کے بیرونی شیل مکمل طور پر بھرے ہوئے ہوتے ہیں جو ان کی کیمیائی غیر متحرکیت کی وضاحت کرتا ہے۔ والینس الیکٹرانوں کی تعداد یہ طے کرتی ہے کہ عنصر کس طرح رد عمل ظاہر کرے گا — کہ آیا وہ الیکٹران کھو دے گا جیسے دھاتوں میں ہوتا ہے، الیکٹران حاصل کرے گا جیسے غیر دھاتوں میں ہوتا ہے یا مشترکہ باندھنے میں الیکٹران شیئر کرے گا۔	الیکٹرانک ترتیب کا آئنوں کی تشکیل سے براہ راست تعلق ہے۔ جب دھاتی ایٹم ایک مثبت آئن بنانے کے لیے الیکٹران کھو دیتا ہے، تو وہ اپنے بیرونی شیل سے الیکٹران کھو دیتا ہے۔ مثال کے طور پر، سوڈیئم 2,8,1 ایک الیکٹران کھو دیتا ہے اور Na⁺ بناتا ہے جس کی ترتیب 2,8 ہوتی ہے، جو نیون جیسی ہوتی ہے۔ جب غیر دھاتی ایٹم ایک منفی آئن بنانے کے لیے الیکٹران حاصل کرتا ہے، تو الیکٹران بیرونی شیل میں شامل ہوتے ہیں۔ مثال کے طور پر، کلورین 2,8,7 ایک الیکٹران حاصل کرتا ہے اور Cl⁻ بناتا ہے جس کی ترتیب 2,8,8 ہوتی ہے، جو آرگون جیسی ہوتی ہے۔ نوبل گیس کی ترتیب حاصل کرنے کی یہ趨势 کیمیائی رد عمل کی بہت سی وجہ ہے۔	\N	/api/media/audio/2.3_en.mp3	{"markdown": "# Electronic Configuration\\n\\n## Definition\\n### Arrangement of Electrons\\n- Electrons in shells\\n- Energy levels order\\n### Shell Capacity Rules\\n- First shell: 2 electrons\\n- Others: 8 electrons maximum\\n\\n## Key Patterns\\n### Filling Order\\n- Innermost shell first\\n- Increasing energy levels\\n### Period and Group\\n- Period = shell number\\n- Group = valence electrons\\n\\n## Examples\\n### First 20 Elements\\n- Hydrogen: 1\\n- Sodium: 2,8,1\\n- Calcium: 2,8,8,2\\n### Noble Gases\\n- Neon: 2,8\\n- Argon: 2,8,8\\n\\n## Ion Formation\\n### Metal Ions\\n- Lose outer electrons\\n- Form positive ions\\n### Non-metal Ions\\n- Gain outer electrons\\n- Form negative ions\\n\\n## Exam Tips\\n- Write configurations systematically\\n- Link to reactivity\\n- Noble gas stability"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
3.2	3	Changes of State	A change of state is a physical change in which a substance transforms from one state of matter to another. The six changes of state are melting, freezing, evaporation, condensation, sublimation, and deposition. Melting is the change from solid to liquid, occurring when a solid is heated to its melting point. Freezing is the reverse process — the change from liquid to solid when a liquid is cooled. These two processes occur at the same temperature for a given substance, which is called both the melting point and the freezing point.	Evaporation and boiling are both processes by which a liquid changes to a gas, but they differ in important ways. Evaporation occurs at the surface of a liquid at any temperature below the boiling point, as some particles near the surface have enough energy to escape into the gas phase. Boiling occurs throughout the entire liquid when its temperature reaches the boiling point and bubbles of vapor form throughout. Condensation is the reverse of evaporation — the change from gas to liquid when a gas is cooled. Sublimation is the direct change from solid to gas without passing through the liquid state, as seen with dry ice which is solid carbon dioxide.	Energy is involved in all changes of state. When a substance melts or evaporates, energy must be supplied to overcome the forces between particles. This energy is called latent heat and it does not change the temperature of the substance — instead it all goes into breaking intermolecular forces. This is why the temperature of melting ice remains at 0°C until all the ice has melted. When a substance freezes or condenses, this same energy is released back to the surroundings. The specific latent heat of fusion is the energy needed to melt one kilogram of a substance at its melting point without changing its temperature.	The melting point and boiling point of a substance are characteristic physical properties that can be used to identify it and assess its purity. A pure substance has a sharp, well-defined melting point, while an impure substance melts over a range of temperatures. The presence of dissolved impurities lowers the melting point and raises the boiling point of a substance — this is called freezing point depression and boiling point elevation respectively. These colligative properties depend only on the number of dissolved particles, not on their chemical identity, and have practical applications such as adding salt to roads in winter to prevent ice formation.	\N	animation	/api/media/animations/3.2_animation.mp4	Watch as the ice cube transitions from solid to liquid—this is melting, which occurs when we heat the solid to its melting point. Notice how the thermometer stays constant at 0°C even though heat is being added. This is because the energy is breaking intermolecular forces rather than raising temperature—we call this latent heat. Observe that freezing is simply the reverse process, and both occur at the same temperature for any given substance.\n\nNow look at the beaker of water. See how particles escape from the surface even below the boiling point? This is evaporation. Pay attention to what happens when we reach 100°C—bubbles form throughout the entire liquid. This is boiling, which differs from evaporation by occurring throughout the liquid rather than just at the surface. Watch as the vapor cools and returns to liquid through condensation.\n\nNotice the dry ice releasing gas directly without becoming liquid first—this direct solid-to-gas transformation is called sublimation. The reverse process is deposition.\n\nObserve how the presence of salt affects these processes. See how the impure substance melts over a range of temperatures rather than at a sharp point? Notice that dissolved impurities lower the melting point but raise the boiling point—these colligative properties depend only on the number of particles present. This is why we spread salt on icy roads in winter.	مادة کی حالت میں تبدیلی ایک 物理اتی تبدیلی ہے جس میں کوئی مادہ ایک حالت سے دوسری حالت میں تبدیل ہو جاتا ہے۔ حالت کی چھ تبدیلیاں پگھلنا، جمنا، بخارات بننا، تقطیر، برف بننا، اور جمع ہونا ہیں۔ پگھلنا ٹھوس سے مائع میں تبدیلی ہے، جو ٹھوس کو اس کی پگھلنے کی نقطہ پر گرم کرنے پر ہوتا ہے۔ جمنا اس کے برعکس عمل ہے — مائع سے ٹھوس میں تبدیلی جب مائع کو ٹھنڈا کیا جاتا ہے۔ یہ دونوں عمل کسی دیئے گئے مادہ کے لیے ایک ہی درجہ حرارت پر ہوتے ہیں، جو دونوں پگھلنے کی نقطہ اور جمنے کی نقطہ کہلاتے ہیں۔	بخارات بننا اور ابال دونوں ایسے عمل ہیں جن میں مائع گیس میں تبدیل ہو جاتا ہے، لیکن وہ اہم پہلوؤں میں مختلف ہیں۔ بخارات بننا مائع کی سطح پر کسی بھی درجہ حرارت پر ہوتا ہے جو ابال کے نقطہ سے نیچے ہو، کیونکہ سطح کے قریب کے کچھ ذرات گیس کی فاز میں فرار ہونے کے لیے کافی توانائی رکھتے ہیں۔ ابال پورا مائع ہوتا ہے جب اس کا درجہ حرارت ابال کے نقطہ پر پہنچ جاتا ہے اور پورا مائع بھاپ کے بلبلے بن جاتے ہیں۔ تقطیر بخارات بننے کے برعکس ہے — گیس سے مائع میں تبدیلی جب گیس کو ٹھنڈا کیا جاتا ہے۔ برف بننا ٹھوس سے گیس میں براہ راست تبدیلی ہے مائع کے ذریعے گزرے بغیر، جیسا کہ خشک برف کے ساتھ ہوتا ہے جو ٹھوس کاربن ڈائی آکسائیڈ ہے۔	تمام حالت کی تبدیلیوں میں توانائی شامل ہوتی ہے۔ جب کوئی مادہ پگھلتا ہے یا بخارات بنتا ہے، تو ذرات کے درمیان قوتوں کو دور کرنے کے لیے توانائی کی فراہمی ضروری ہوتی ہے۔ اس توانائی کو لاطینی حرارت کہتے ہیں اور یہ مادہ کے درجہ حرارت کو نہیں بدलतا — بلکہ یہ سارا بین الجزیوی قوتوں کو توڑنے میں چلا جاتا ہے۔ یہی وجہ ہے کہ پگھلنے والی برف کا درجہ حرارت 0°C پر برقرار رہتا ہے یہاں تک کہ ساری برف پگھل نہیں جاتی۔ جب کوئی مادہ جمتا ہے یا تقطیر ہوتا ہے، تو یہی توانائی ماحول میں واپس آ جاتی ہے۔ جماؤ کی مخصوص لاطینی حرارت وہ توانائی ہے جو کسی مادہ کے ایک کلو گرام کو اس کی پگھلنے کی نقطہ پر پگھلنے کے لیے درکار ہوتی ہے بغیر اس کے درجہ حرارت کو بدلے۔	کسی مادہ کا پگھلنے کا نقطہ اور ابال کا نقطہ اس کی特征 fizikai خصوصیات ہیں جو اس کی شناخت اور اس کی صفائی کو جانچنے کے لیے استعمال کی جا سکتی ہیں۔ ایک خالص مادہ کا ایک تیز، واضح پگھلنے کا نقطہ ہوتا ہے، جبکہ ایک غیر خالص مادہ درجہ حرارت کے ایک سلسلے میں پگھلتا ہے۔ حل شدہ अशुदھیوں کی موجودگی پگھلنے کے نقطہ کو کم کر دیتی ہے اور ابال کے نقطہ کو بڑھا دیتی ہے — اسے جماؤ کا دباؤ اور ابال کا دباؤ کہتے ہیں۔ یہ جماعی خصوصیات حل شدہ ذرات کی تعداد پر منحصر ہوتی ہیں، نہ کہ ان کی کیمیائی شناخت پر، اور ان کے عملی اطلاق ہوتے ہیں جیسے کہ سڑکوں پر سردیوں میں برف کی تشکیل کو روکنے کے لیے نمک ڈالنا۔	\N	/api/media/audio/3.2_en.mp3	{"markdown": "# Changes of State\\n\\n## Definition\\n- Physical change process\\n- State transformation occurs\\n\\n## Six State Changes\\n### Solid-Liquid Transitions\\n- Melting requires heating\\n- Freezing requires cooling\\n### Liquid-Gas Transitions\\n- Evaporation at surface\\n- Boiling throughout liquid\\n### Direct Solid-Gas\\n- Sublimation bypasses liquid\\n- Deposition reverse process\\n\\n## Energy and Latent Heat\\n### Energy Requirements\\n- Breaking intermolecular forces\\n- Temperature remains constant\\n### Latent Heat Types\\n- Fusion for melting\\n- Vaporization for boiling\\n\\n## Melting and Boiling Points\\n### Pure Substances\\n- Sharp defined points\\n- Identify and characterize\\n### Impure Substances\\n- Melting point lowered\\n- Boiling point raised\\n\\n## Exam Tips\\n- Know all six changes\\n- Temperature constant during change\\n- Impurities affect points"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
3.3	3	Diffusion	Diffusion is the net movement of particles from a region of higher concentration to a region of lower concentration, down a concentration gradient. This process occurs as a result of the random motion of particles and requires no energy input — it happens spontaneously. Diffusion continues until the particles are evenly distributed throughout the available space, at which point the concentration is uniform everywhere and a state of dynamic equilibrium is reached. At equilibrium, particles continue to move randomly, but there is no net movement in any direction.	Diffusion occurs in both gases and liquids but is much faster in gases because gas particles move more rapidly and have more space between them. The rate of diffusion in gases is demonstrated by the experiment where ammonia gas and hydrogen chloride gas are released simultaneously from opposite ends of a glass tube. A white ring of ammonium chloride forms in the tube where the two gases meet. The ring forms closer to the hydrogen chloride end because ammonia molecules, being lighter, diffuse faster. This demonstrates that lighter molecules diffuse more quickly, as described by Graham's law of diffusion.	Several factors affect the rate of diffusion. Temperature has a significant effect — higher temperatures give particles more kinetic energy, causing them to move faster and diffuse more quickly. The molecular mass of the diffusing substance also affects the rate — lighter molecules move faster and diffuse more quickly than heavier molecules at the same temperature. The concentration gradient affects the rate as well — a steeper gradient means faster net diffusion. In liquids, the viscosity of the liquid affects how quickly particles can move through it, with less viscous liquids allowing faster diffusion.	Diffusion is essential to many biological and industrial processes. In the human body, oxygen diffuses from the air in the lungs into the blood, and carbon dioxide diffuses in the opposite direction. Nutrients diffuse from the blood into body cells, while waste products diffuse out. In plants, carbon dioxide diffuses into leaves through tiny pores called stomata for use in photosynthesis. In industrial processes, diffusion is important in dialysis, where waste products diffuse from the blood through a semi-permeable membrane during kidney dialysis treatment. Understanding diffusion is therefore fundamental to both biology and chemistry.	\N	animation	/api/media/animations/3.3_animation.mp4	Notice how the particles begin spread throughout the container, moving from the area where they're crowded toward the empty spaces. Watch as this movement happens spontaneously, with no energy required—the particles are simply moving randomly. Observe that over time, the particles spread more evenly until they're distributed uniformly throughout the space. Pay attention to how the particles continue moving even after they're evenly spread, but there's no longer any net movement in one direction. This is dynamic equilibrium.\n\nSee how diffusion occurs much faster in the gas container compared to the liquid. Look at the experiment where ammonia and hydrogen chloride gases are released from opposite ends of the tube. Notice how the white ring of ammonium chloride forms closer to the hydrogen chloride end—this happens because the lighter ammonia molecules diffuse faster, demonstrating Graham's law.\n\nWatch as the temperature increases and the particles move more rapidly, speeding up diffusion. Observe that lighter molecules consistently diffuse faster than heavier ones at the same temperature. Notice how a steeper concentration gradient produces faster diffusion, while increased viscosity in liquids slows the process down.\n\nYou can see these principles at work in real-world examples: oxygen diffusing into blood in the lungs, carbon dioxide entering plant leaves through stomata, and waste products diffusing through membranes during kidney dialysis. Each process depends on this fundamental movement of particles down their concentration gradient.	خلاتی تحریک اس علاقے سے دوسرے علاقے کی طرف ذرے کا مجموعی حرکت ہے جہاں کثافت زیادہ ہو، وہاں سے اس علاقے کی طرف جہاں کثافت کم ہو، کثافت کے گرادیئنٹ کے نیچے۔ یہ عمل ذرے کی بے ترتیبی حرکت کے نتیجے میں ہوتا ہے اور اس میں کوئی توانائی کی ضرورت نہیں ہوتی — یہ خود بخود ہوتا ہے۔ خلاتی تحریک اس وقت تک جاری رہتی ہے جب تک کہ ذرے دستیاب خلا میں یکساں طور پر تقسیم نہیں ہو جاتے، جس مقام پر کثافت ہر جگہ ایک جیسا ہو جاتا ہے اور ایک متحرک توازن کی حالت حاصل ہو جاتی ہے۔ توازن پر، ذرے بے ترتیبی سے حرکت کرتے رہتے ہیں، لیکن کوئی بھی جہتی مجموعی حرکت نہیں ہوتی۔	خلاتی تحریک گیسوں اور مائع دونوں میں ہوتی ہے لیکن گیسوں میں یہ بہت تیزی سے ہوتی ہے کیونکہ گیس کے ذرے زیادہ تیزی سے حرکت کرتے ہیں اور ان کے درمیان زیادہ خلا ہوتا ہے۔ گیسوں میں خلاتی تحریک کی شرح اس تجربے سے ظاہر ہوتی ہے جہاں امونیا گیس اور ہائیڈروجن کلورائیڈ گیس کو شیشے کی نلی کے دونوں سرے سے ایک ساتھ چھوڑا جاتا ہے۔ نلی میں دونوں گیسوں کے ملنے کی جگہ ایک سفید رنگ کا امونیا کلورائیڈ کا حلقہ بنتا ہے۔ یہ حلقہ ہائیڈروجن کلورائیڈ کے سرے کے قریب بنتا ہے کیونکہ امونیا کے مالیکول، ہلکے ہونے کی وجہ سے، تیزی سے خلاتی تحریک کرتے ہیں۔ یہ ظاہر کرتا ہے کہ ہلکے مالیکول تیزی سے خلاتی تحریک کرتے ہیں، جیسا کہ گریہم کے خلاتی تحریک کے قانون میں بیان کیا گیا ہے۔	خلاتی تحریک کی شرح کوئی بہت سے عوامل متاثر کرتے ہیں۔ درجہ حرارت کا اثر بہت زیادہ ہوتا ہے — زیادہ درجہ حرارت ذرے کو زیادہ جننی توانائی دیتا ہے، جس کی وجہ سے وہ تیزی سے حرکت کرتے ہیں اور خلاتی تحریک تیزی سے ہوتی ہے۔ خلاتی تحریک کرنے والے مادے کی مالیکیولر کمیت بھی شرح کو متاثر کرتی ہے — ہلکے مالیکول تیزی سے حرکت کرتے ہیں اور ایک ہی درجہ حرارت پر بھاری مالیکول کے مقابلے میں تیزی سے خلاتی تحریک کرتے ہیں۔ کثافت کا گرادیئنٹ بھی شرح کو متاثر کرتا ہے — ایک تیز گرادیئنٹ کا مطلب تیزی سے خالص خلاتی تحریک ہے۔ مائع میں، مائع کی ساپیکش گھناؤنیت یہ متاثر کرتی ہے کہ ذرے اس کے ذریعے کتنی تیزی سے حرکت کر سکتے ہیں، کم گھناؤنیت والے مائع خلاتی تحریک کی اجازت دیتے ہیں۔	خلاتی تحریک بہت سے حیاتیاتی اور صنعتی عمل کے لیے ضروری ہے۔ انسانی جسم میں، آکسیجن پھیپھڑوں میں موجود ہوا سے خون میں خلاتی تحریک کرتی ہے، اور کاربن ڈائی آکسائیڈ برعکس سمت میں خلاتی تحریک کرتی ہے۔ غذائی اجزا خون سے جسم کے خلیوں میں خلاتی تحریک کرتے ہیں، جبکہ فضلے کے اجزا باہر کی طرف خلاتی تحریک کرتے ہیں۔ پودوں میں، کاربن ڈائی آکسائیڈ پھوتو سنسٹھیسس کے لیے استعمال ہونے والی پتیوں میں چھوٹے چھیدوں کے ذریعے خلاتی تحریک کرتی ہے۔ صنعتی عمل میں، خلاتی تحریک ڈائیلیسس میں اہم ہے، جہاں فضلے کے اجزا خون سے آدھی قابل گذر membrane کے ذریعے گُزرتے ہیں۔ اس لیے خلاتی تحریک کی سمجھ حیاتیات اور کیمیا دونوں کے لیے بنیادی ہے۔	\N	/api/media/audio/3.3_en.mp3	{"markdown": "# Diffusion\\n\\n## Definition\\n### Net Particle Movement\\n- Higher to lower concentration\\n- Down concentration gradient\\n### Spontaneous Process\\n- Random particle motion\\n- No energy required\\n\\n## Key Properties\\n### Dynamic Equilibrium\\n- Uniform concentration reached\\n- Continuous random movement\\n### Speed in States\\n- Faster in gases\\n- Slower in liquids\\n\\n## Factors Affecting Rate\\n### Temperature Effect\\n- Higher temperature faster\\n- More kinetic energy\\n### Molecular Mass Effect\\n- Lighter molecules faster\\n- Graham's law applies\\n### Concentration Gradient\\n- Steeper gradient faster\\n\\n## Examples\\n### Gas Diffusion\\n- Ammonia and HCl\\n- White ammonium chloride\\n### Biological Processes\\n- Oxygen into blood\\n- CO₂ through stomata\\n\\n## Exam Tips\\n- Define down gradient\\n- State affecting factors\\n- Use ammonia experiment"}	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
4.3	4	Rate of Reaction	The rate of a chemical reaction is a measure of how fast reactants are converted into products. It can be defined as the change in concentration of a reactant or product per unit time. Reactions can occur at vastly different rates — some reactions like explosions happen in microseconds, while others like the rusting of iron take years. The rate of a reaction is determined by how frequently reactant particles collide with sufficient energy and in the correct orientation to react. This is the basis of collision theory, which explains why and how reaction rates change.	Concentration is one of the main factors affecting the rate of a reaction. Increasing the concentration of reactants in solution increases the number of particles per unit volume, which increases the frequency of collisions between reactant particles. More frequent collisions lead to a higher rate of reaction. For reactions involving gases, increasing the pressure has a similar effect — it decreases the volume, effectively increasing the concentration of gas molecules and leading to more frequent collisions. The relationship between concentration and rate is described by the rate law or rate equation for a specific reaction.	Temperature has a dramatic effect on reaction rate. Increasing the temperature increases the kinetic energy of the particles, causing them to move faster and collide more frequently. More importantly, a higher temperature means more particles have energy equal to or greater than the activation energy. Even a small increase in temperature significantly increases the fraction of particles with sufficient energy to react. As a general rule, a 10°C rise in temperature approximately doubles the rate of many reactions. This relationship between temperature and reaction rate has important implications for industrial processes and for understanding biological enzyme activity.	Surface area plays an important role in the rate of reactions involving solids. When a solid reactant is broken into smaller pieces or ground into a powder, its surface area increases dramatically. Since reactions can only occur when particles come into contact with the surface of a solid, a larger surface area means more reactant particles are exposed and available for collision. This is why powdered calcium carbonate reacts much more rapidly with hydrochloric acid than marble chips of the same mass. This principle explains why flour dust in grain silos can be explosively reactive despite flour being completely non-explosive in bulk.	Catalysts are substances that increase the rate of a chemical reaction without being used up in the process. They work by providing an alternative reaction pathway with a lower activation energy, allowing more particles to have sufficient energy to react successfully. Because catalysts are not consumed in the reaction, a small amount can catalyze the conversion of large amounts of reactants into products. Catalysts are divided into homogeneous catalysts, which are in the same phase as the reactants, and heterogeneous catalysts, which are in a different phase. Industrial examples include iron catalyst in the Haber process for ammonia synthesis and platinum catalyst in catalytic converters.	animation	/api/media/animations/4.3_animation.mp4	Notice how the reactant particles are constantly moving and colliding with one another. Watch as only those collisions with sufficient energy and the correct orientation result in a successful reaction, forming products. This is the foundation of collision theory.\n\nObserve that when we increase the concentration of reactants in the solution, there are more particles present in the same space. See how this leads to more frequent collisions between particles, directly increasing the rate of reaction. Pay attention to what happens with gases under pressure—the decreased volume has the same effect as increasing concentration, packing molecules closer together.\n\nNow watch as we raise the temperature. Notice how the particles begin moving much faster, colliding more frequently. More importantly, look at how many more particles now possess energy exceeding the activation energy threshold. Even a small 10°C temperature increase can approximately double the reaction rate for many processes.\n\nObserve what happens when we break a solid reactant into smaller pieces. See how the surface area increases dramatically, exposing more reactant particles to collision. This explains why powdered substances react so much faster than larger chunks—and why flour dust can be explosively dangerous despite flour being safe in bulk.\n\nFinally, pay attention to how catalysts provide an alternative pathway with lower activation energy. Notice that the catalyst emerges unchanged, ready to facilitate countless more reactions without being consumed.	\N	\N	\N	\N	\N	\N	\N	2026-04-17 09:30:24.609032	2026-04-17 09:30:24.609032
\.


--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_preferences (user_id, current_format, recommended_format, updated_at) FROM stdin;
5	\N	lecture	2026-04-24 20:37:19.324156
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, role, is_verified, profile_picture_url, created_at, last_login) FROM stdin;
7	admin@edutailor.com	scrypt:32768:8:1$Eom8gpYATmPpWVa1$d709862aaaccf765736d0e28a496492a8f8fbde793b710dba50cfc43ef211d0ebd078a8f4169f0314edfb3b358ed8636b4f0935725b133dc1ed10f4eeb24ac17	EduTailor Admin	admin	t	\N	2026-04-24 16:03:47.315961	2026-04-24 17:28:51.537877
8	mushtaqubaid9@gmail.com	scrypt:32768:8:1$94NG46vWbV0qZsOZ$12f3ff382ec1da50922974dbf044ca3d4e0e31bfc7dac5db1bdb19093bc28f9e330772c67457ad56c0e5cbb4f2efb80b69ab54ef62e3f731eb9220b9b0ddb921	Mushtaq Ubaid	teacher	f	\N	2026-04-24 17:28:25.107927	2026-04-24 17:28:42.956957
6	romanfarooqi0@gmail.com	scrypt:32768:8:1$56RrU4Li23fr0Zt6$bfee7e4b1a67b1a2376a6ebd891a4685216c845a36e13f43f31694afe2c48b3df8f1505e9077d1bb3bc08e99b130a4deef5657ad9a956ee444df89a076753517	Roman Farooqi	student	f	\N	2026-04-19 18:51:25.667955	\N
5	mushtaqubaid89@gmail.com	scrypt:32768:8:1$VAgWT1gRp7toK05C$7b90251d8335d3e429247957d9637bcba709a6662a18c904e34d7294c89258131a023e10899edf5f48703c281914bf1e2eed6253019e9f4de977abb2615c0d7b	Mushtaq Ubaid	student	t	/media/profiles/user_5.jpg	2026-04-17 14:29:51.735176	2026-04-24 20:36:52.352308
3	mushtaqubaid661@gmail.com	scrypt:32768:8:1$2w7Rp6Xv0jNbUcqZ$832c64588e40971806b75ae37989f465772a9bc9d9ab02b9d2a88a1e47111d16060b6da2a5593df70f2d2acd583ef64d6e17de4433d0f3f7ee16f3c23989738d	Test Teacher	teacher	t	\N	2026-04-17 14:03:18.374362	2026-04-24 20:38:13.236568
\.


--
-- Data for Name: vark_assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vark_assessments (id, user_id, visual_score, auditory_score, reading_score, kinesthetic_score, recommended_format, assessed_at) FROM stdin;
1	5	3	10	5	0	auditory	2026-04-24 20:37:19.331927
\.


--
-- Name: bookmarks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookmarks_id_seq', 5, true);


--
-- Name: chapters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chapters_id_seq', 5, true);


--
-- Name: content_generation_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.content_generation_log_id_seq', 1, false);


--
-- Name: content_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.content_status_id_seq', 100, true);


--
-- Name: feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feedback_id_seq', 1, true);


--
-- Name: format_tracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.format_tracking_id_seq', 76, true);


--
-- Name: highlights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.highlights_id_seq', 11, true);


--
-- Name: lecture_slides_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lecture_slides_id_seq', 83, true);


--
-- Name: note_clips_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.note_clips_id_seq', 4, true);


--
-- Name: notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notes_id_seq', 29, true);


--
-- Name: otp_verifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otp_verifications_id_seq', 7, true);


--
-- Name: question_performance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.question_performance_id_seq', 1, false);


--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_attempts_id_seq', 12, true);


--
-- Name: student_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_questions_id_seq', 28, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- Name: vark_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vark_assessments_id_seq', 1, true);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: chapters chapters_chapter_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_chapter_number_key UNIQUE (chapter_number);


--
-- Name: chapters chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: content_generation_log content_generation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_generation_log
    ADD CONSTRAINT content_generation_log_pkey PRIMARY KEY (id);


--
-- Name: content_status content_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_status
    ADD CONSTRAINT content_status_pkey PRIMARY KEY (id);


--
-- Name: content_status content_status_topic_id_content_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_status
    ADD CONSTRAINT content_status_topic_id_content_type_key UNIQUE (topic_id, content_type);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- Name: format_tracking format_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format_tracking
    ADD CONSTRAINT format_tracking_pkey PRIMARY KEY (id);


--
-- Name: highlights highlights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_pkey PRIMARY KEY (id);


--
-- Name: lecture_slides lecture_slides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecture_slides
    ADD CONSTRAINT lecture_slides_pkey PRIMARY KEY (id);


--
-- Name: lecture_slides lecture_slides_topic_id_slide_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecture_slides
    ADD CONSTRAINT lecture_slides_topic_id_slide_number_key UNIQUE (topic_id, slide_number);


--
-- Name: note_clips note_clips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note_clips
    ADD CONSTRAINT note_clips_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notes notes_user_id_topic_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_user_id_topic_id_key UNIQUE (user_id, topic_id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: question_performance question_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_performance
    ADD CONSTRAINT question_performance_pkey PRIMARY KEY (id);


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id);


--
-- Name: student_progress student_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_progress
    ADD CONSTRAINT student_progress_pkey PRIMARY KEY (user_id, topic_id);


--
-- Name: student_questions student_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_questions
    ADD CONSTRAINT student_questions_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (topic_id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vark_assessments vark_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vark_assessments
    ADD CONSTRAINT vark_assessments_pkey PRIMARY KEY (id);


--
-- Name: idx_content_status_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_content_status_status ON public.content_status USING btree (status);


--
-- Name: idx_content_status_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_content_status_topic ON public.content_status USING btree (topic_id);


--
-- Name: idx_feedback_rating; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_rating ON public.feedback USING btree (rating);


--
-- Name: idx_feedback_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_topic ON public.feedback USING btree (topic_id);


--
-- Name: idx_format_tracking_format; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_format_tracking_format ON public.format_tracking USING btree (format);


--
-- Name: idx_format_tracking_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_format_tracking_topic ON public.format_tracking USING btree (topic_id);


--
-- Name: idx_format_tracking_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_format_tracking_user ON public.format_tracking USING btree (user_id);


--
-- Name: idx_gen_log_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gen_log_topic ON public.content_generation_log USING btree (topic_id);


--
-- Name: idx_lecture_slides_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lecture_slides_topic ON public.lecture_slides USING btree (topic_id);


--
-- Name: idx_progress_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_progress_status ON public.student_progress USING btree (status);


--
-- Name: idx_progress_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_progress_user ON public.student_progress USING btree (user_id);


--
-- Name: idx_question_perf_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_question_perf_topic ON public.question_performance USING btree (topic_id);


--
-- Name: idx_question_perf_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_question_perf_type ON public.question_performance USING btree (question_type);


--
-- Name: idx_questions_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_topic ON public.student_questions USING btree (topic_id);


--
-- Name: idx_questions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_user ON public.student_questions USING btree (user_id);


--
-- Name: idx_quiz_attempted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_attempted ON public.quiz_attempts USING btree (attempted_at);


--
-- Name: idx_quiz_format; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_format ON public.quiz_attempts USING btree (format_used);


--
-- Name: idx_quiz_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_topic ON public.quiz_attempts USING btree (topic_id);


--
-- Name: idx_quiz_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quiz_user ON public.quiz_attempts USING btree (user_id);


--
-- Name: idx_topics_chapter; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_topics_chapter ON public.topics USING btree (chapter_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_vark_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vark_user ON public.vark_assessments USING btree (user_id);


--
-- Name: bookmarks bookmarks_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: bookmarks bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: content_generation_log content_generation_log_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_generation_log
    ADD CONSTRAINT content_generation_log_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: content_status content_status_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_status
    ADD CONSTRAINT content_status_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: content_status content_status_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_status
    ADD CONSTRAINT content_status_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: feedback feedback_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: feedback feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: format_tracking format_tracking_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format_tracking
    ADD CONSTRAINT format_tracking_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: format_tracking format_tracking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.format_tracking
    ADD CONSTRAINT format_tracking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: highlights highlights_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: highlights highlights_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lecture_slides lecture_slides_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecture_slides
    ADD CONSTRAINT lecture_slides_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id) ON DELETE CASCADE;


--
-- Name: note_clips note_clips_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note_clips
    ADD CONSTRAINT note_clips_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: note_clips note_clips_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note_clips
    ADD CONSTRAINT note_clips_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notes notes_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: notes notes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: otp_verifications otp_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: question_performance question_performance_quiz_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_performance
    ADD CONSTRAINT question_performance_quiz_attempt_id_fkey FOREIGN KEY (quiz_attempt_id) REFERENCES public.quiz_attempts(id) ON DELETE CASCADE;


--
-- Name: question_performance question_performance_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_performance
    ADD CONSTRAINT question_performance_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: question_performance question_performance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_performance
    ADD CONSTRAINT question_performance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quiz_attempts quiz_attempts_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: quiz_attempts quiz_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_progress student_progress_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_progress
    ADD CONSTRAINT student_progress_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: student_progress student_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_progress
    ADD CONSTRAINT student_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_questions student_questions_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_questions
    ADD CONSTRAINT student_questions_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id);


--
-- Name: student_questions student_questions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_questions
    ADD CONSTRAINT student_questions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: topics topics_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.chapters(id);


--
-- Name: user_preferences user_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: vark_assessments vark_assessments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vark_assessments
    ADD CONSTRAINT vark_assessments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict z2QuiW8KzWio9G67PdMtNPu4kiLOUH1hUwkLBbNQWiDj4J7jFP9gdMuYUhQqPYd

