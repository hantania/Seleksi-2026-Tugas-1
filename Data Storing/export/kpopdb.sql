--
-- PostgreSQL database dump
--

\restrict ho5n818B7m4cYFWS6F3bsJfcUpcy8gXUseXVELISkdn2BMk24927VjhwFCL8yKw

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: group_status_changed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.group_status_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'ACTIVE' THEN
        INSERT INTO active_groups(ID_group) 
        VALUES (NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM disbanded_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM hiatus_groups WHERE ID_group = NEW.ID_group;
    ELSIF NEW.status = 'DISBANDED' THEN
        INSERT INTO disbanded_groups(ID_group) 
        VALUES(NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM active_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM hiatus_groups WHERE ID_group = NEW.ID_group;
    ELSIF NEW.status = 'HIATUS' THEN
        INSERT INTO hiatus_groups(ID_group) 
        VALUES(NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM active_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM disbanded_groups WHERE ID_group = NEW.ID_group;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.group_status_changed() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.active_groups (
    id_group integer NOT NULL,
    latest_comeback_date date
);


ALTER TABLE public.active_groups OWNER TO postgres;

--
-- Name: albums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.albums (
    id_album integer NOT NULL,
    id_group integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(30),
    release_date date,
    language character varying(30),
    description text
);


ALTER TABLE public.albums OWNER TO postgres;

--
-- Name: albums_id_album_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.albums_id_album_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.albums_id_album_seq OWNER TO postgres;

--
-- Name: albums_id_album_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.albums_id_album_seq OWNED BY public.albums.id_album;


--
-- Name: disbanded_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.disbanded_groups (
    id_group integer NOT NULL,
    disband_year integer,
    disband_reason character varying(200)
);


ALTER TABLE public.disbanded_groups OWNER TO postgres;

--
-- Name: fandom_colors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fandom_colors (
    id_fandom integer NOT NULL,
    color_identity character varying(30) NOT NULL
);


ALTER TABLE public.fandom_colors OWNER TO postgres;

--
-- Name: fandoms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fandoms (
    id_fandom integer NOT NULL,
    id_group integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.fandoms OWNER TO postgres;

--
-- Name: fandoms_id_fandom_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fandoms_id_fandom_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fandoms_id_fandom_seq OWNER TO postgres;

--
-- Name: fandoms_id_fandom_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fandoms_id_fandom_seq OWNED BY public.fandoms.id_fandom;


--
-- Name: fans_fandoms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fans_fandoms (
    id_user integer NOT NULL,
    id_fandom integer NOT NULL
);


ALTER TABLE public.fans_fandoms OWNER TO postgres;

--
-- Name: fans_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fans_users (
    id_user integer NOT NULL,
    username character varying(100) NOT NULL,
    level smallint,
    register_date date,
    CONSTRAINT fans_users_level_check CHECK (((level >= 1) AND (level <= 5)))
);


ALTER TABLE public.fans_users OWNER TO postgres;

--
-- Name: fans_users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fans_users_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fans_users_id_user_seq OWNER TO postgres;

--
-- Name: fans_users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fans_users_id_user_seq OWNED BY public.fans_users.id_user;


--
-- Name: fans_vote_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fans_vote_groups (
    id_user integer NOT NULL,
    id_group integer NOT NULL,
    id_voting integer NOT NULL,
    vote_timestamp timestamp without time zone NOT NULL
);


ALTER TABLE public.fans_vote_groups OWNER TO postgres;

--
-- Name: group_idols; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_idols (
    id_group integer NOT NULL,
    id_idol integer NOT NULL,
    role character varying(25) NOT NULL,
    CONSTRAINT group_idols_role_check CHECK (((role)::text = ANY ((ARRAY['RAPPER'::character varying, 'VOCALIST'::character varying, 'LEADER'::character varying, 'DANCER'::character varying, 'VISUAL'::character varying, 'OTHERS'::character varying])::text[])))
);


ALTER TABLE public.group_idols OWNER TO postgres;

--
-- Name: group_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_metrics (
    id_group integer NOT NULL,
    scraped_at timestamp without time zone NOT NULL,
    rank integer,
    total_bias_votes integer,
    dance_score numeric(5,2),
    vocal_score numeric(5,2),
    stage_score numeric(5,2),
    artistry_score numeric(5,2),
    visual_score numeric(5,2)
);


ALTER TABLE public.group_metrics OWNER TO postgres;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id_group integer NOT NULL,
    id_label integer,
    name character varying(100) NOT NULL,
    other_name character varying(100),
    status character varying(15),
    debut_date date,
    id_parent_group integer,
    CONSTRAINT groups_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'DISBANDED'::character varying, 'HIATUS'::character varying])::text[])))
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_group_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_group_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_group_seq OWNER TO postgres;

--
-- Name: groups_id_group_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_group_seq OWNED BY public.groups.id_group;


--
-- Name: hiatus_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hiatus_groups (
    id_group integer NOT NULL,
    hiatus_year integer,
    hiatus_reason character varying(200)
);


ALTER TABLE public.hiatus_groups OWNER TO postgres;

--
-- Name: idols; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.idols (
    id_idol integer NOT NULL,
    stage_name character varying(50) NOT NULL,
    full_name character varying(100) NOT NULL,
    birthday date,
    birth_adm_area character varying(100),
    birth_country character varying(100),
    height numeric(5,2)
);


ALTER TABLE public.idols OWNER TO postgres;

--
-- Name: idols_id_idol_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.idols_id_idol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.idols_id_idol_seq OWNER TO postgres;

--
-- Name: idols_id_idol_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.idols_id_idol_seq OWNED BY public.idols.id_idol;


--
-- Name: labels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.labels (
    id_label integer NOT NULL,
    name character varying(100) NOT NULL,
    founded_year integer,
    founder character varying(100)
);


ALTER TABLE public.labels OWNER TO postgres;

--
-- Name: labels_id_label_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.labels_id_label_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.labels_id_label_seq OWNER TO postgres;

--
-- Name: labels_id_label_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.labels_id_label_seq OWNED BY public.labels.id_label;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tracks (
    id_album integer NOT NULL,
    title character varying(200) NOT NULL,
    genre character varying(50)
);


ALTER TABLE public.tracks OWNER TO postgres;

--
-- Name: view_idol_age; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_idol_age AS
 SELECT id_idol,
    stage_name,
    (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (birthday)::timestamp with time zone)))::integer AS age
   FROM public.idols;


ALTER VIEW public.view_idol_age OWNER TO postgres;

--
-- Name: view_total_score; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_total_score AS
 SELECT id_group,
    scraped_at,
    ((((COALESCE(dance_score, (0)::numeric) + COALESCE(vocal_score, (0)::numeric)) + COALESCE(stage_score, (0)::numeric)) + COALESCE(artistry_score, (0)::numeric)) + COALESCE(visual_score, (0)::numeric)) AS total_score
   FROM public.group_metrics;


ALTER VIEW public.view_total_score OWNER TO postgres;

--
-- Name: votings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.votings (
    id_voting integer NOT NULL,
    name character varying(100) NOT NULL,
    start_date date,
    end_date date,
    CONSTRAINT votings_check CHECK ((end_date > start_date))
);


ALTER TABLE public.votings OWNER TO postgres;

--
-- Name: votings_id_voting_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.votings_id_voting_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.votings_id_voting_seq OWNER TO postgres;

--
-- Name: votings_id_voting_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.votings_id_voting_seq OWNED BY public.votings.id_voting;


--
-- Name: albums id_album; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums ALTER COLUMN id_album SET DEFAULT nextval('public.albums_id_album_seq'::regclass);


--
-- Name: fandoms id_fandom; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fandoms ALTER COLUMN id_fandom SET DEFAULT nextval('public.fandoms_id_fandom_seq'::regclass);


--
-- Name: fans_users id_user; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_users ALTER COLUMN id_user SET DEFAULT nextval('public.fans_users_id_user_seq'::regclass);


--
-- Name: groups id_group; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id_group SET DEFAULT nextval('public.groups_id_group_seq'::regclass);


--
-- Name: idols id_idol; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.idols ALTER COLUMN id_idol SET DEFAULT nextval('public.idols_id_idol_seq'::regclass);


--
-- Name: labels id_label; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labels ALTER COLUMN id_label SET DEFAULT nextval('public.labels_id_label_seq'::regclass);


--
-- Name: votings id_voting; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votings ALTER COLUMN id_voting SET DEFAULT nextval('public.votings_id_voting_seq'::regclass);


--
-- Data for Name: active_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.active_groups (id_group, latest_comeback_date) FROM stdin;
1	\N
2	\N
3	\N
4	\N
5	\N
6	\N
7	\N
8	\N
9	\N
10	\N
11	\N
12	\N
13	\N
14	\N
15	\N
16	\N
17	\N
18	\N
19	\N
20	\N
21	\N
22	\N
23	\N
26	\N
27	\N
28	\N
29	\N
30	\N
31	\N
32	\N
33	\N
34	\N
36	\N
38	\N
39	\N
40	\N
41	\N
42	\N
43	\N
44	\N
46	\N
47	\N
48	\N
49	\N
50	\N
51	\N
52	\N
53	\N
55	\N
56	\N
57	\N
58	\N
59	\N
60	\N
61	\N
62	\N
63	\N
64	\N
65	\N
66	\N
69	\N
72	\N
73	\N
74	\N
75	\N
76	\N
80	\N
88	\N
89	\N
92	\N
95	\N
96	\N
100	\N
101	\N
102	\N
104	\N
\.


--
-- Data for Name: albums; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.albums (id_album, id_group, name, type, release_date, language, description) FROM stdin;
1	1	Normal	SINGLE	2026-07-17	Korean	"NORMAL" is a single by BTS. It was released on July 17, 2026. The title track is "NORMAL (Explicit Ver.)."
2	1	Come Over	SINGLE	2026-06-12	Korean	"Come Over" is a song by BTS. It was first released on April 3, 2026, and appears as the fifteenth track on the Deluxe Vinyl version of their fifth studio album ARIRANG.It was released officially on June 12, 2026 as part of the 2026 BTS Festa.
3	1	SWIM (Spring Waves Remix)	SINGLE	2026-04-17	English	"SWIM (Spring Waves Remix)" is a remix single by BTS. It was released on April 17, 2026.
4	1	SWIM (Underwater Remix)	SINGLE	2026-04-10	Korean	On April 10 2026, BTS released the Underwater remix to their song "SWIM".
5	1	KEEP SWIMMING	SINGLE	2026-03-27	Korean	KEEP SWIMMING is a remix single by BTS. The album consists of seven remixes by each member. It was released on March 27, 2026.
6	1	Swim (Instrumental)	SINGLE	2026-03-23	English	"Swim (Instrumental)" is the third digital English single by BTS. It was released on March 23, 2026.
7	1	ARIRANG	STUDIO	2026-03-20	Korean	"ARIRANG" is the sixth Korean-language album by BTS. It was released on March 20, 2026 with "SWIM" serving as the title track.
8	1	Permission To Dance On Stage Live	LIVE	2025-07-18	\N	Permission To Dance On Stage - Live is the first live album by BTS. It was released on July 18, 2025 and consists of recordings from group's fourth world tour, Permission To Dance : On Stage.
9	1	Take Two	SINGLE	2023-06-09	\N	"Take Two" is the fifth digital single by BTS. It was released on June 9, 2023 in celebration of their 10th anniversary since debut.
10	1	The Planet	OST	2023-05-12	\N	"The Planet" is the original soundtrack for the 3D animated superhero series Bastions. It was released on May 12, 2023 and features BTS.
11	2	THIS & THAT	MINI ALBUM	\N	Korean	"THIS & THAT" is the 14th mini album by Stray Kids. It is set to release on August 7, 2026.
12	2	RUN IT	SINGLE	2026-06-24	Korean	"RUN IT" is a pre release  single by Stray Kids. It was released on June 24, 2026.
13	2	STAY	SINGLE	2026-03-25	Korean	"Stay" is the 10th digital single by Stray Kids. It was released on March 25, 2026 coinciding with the group's eighth anniversary.
14	2	Endless Sun	SINGLE	2026-03-13	Korean	On March 13, 2026 Stray Kids released the single "Endless Sun" in collaboration with Biore UV.
15	2	Do It (Remixes)	MINI ALBUM	2025-11-24	\N	On November 24, 2025 Stray Kids released the remixes of their single "Do It".
16	2	In the Dark (with DJ Snake)	SINGLE	2025-11-07	\N	In The Dark is a song recorded by Stray Kids in collaboration with French DJ and record producer DJ Snake.It is the sixth track from DJ Snake's third studio album, Nomad, released on November 7, 2025.
17	2	Do It	MINI ALBUM	2025-11-01	\N	Do It is the second mixtape album released by Stray Kids. It is a follow up to Hop - or SKZhop Hiptape. Do It is also known by the name SKZ It Tape.
18	2	Ceremony (Celebrate Remixes)	SINGLE	2025-08-29	\N	"Ceremony (Celebrate Remixes)" is the fourth remix single by Stray Kids. It was released on August 29, 2025.
19	2	CEREMONY (Maximum Power Remixes)	SINGLE	2025-08-25	\N	"Ceremony (Maximum Power Remixes)" is the third remix single by Stray Kids. It was released on August 25, 2025.
20	2	KARMA	STUDIO	2025-08-22	Korean	Karma (stylized in all caps) is the fourth Korean-language studio album (sixth overall) by South Korean boy band Stray Kids. It was released on August 22, 2025, through JYP Entertainment and Republic Records. The album serves as their first full-length Korean studio album since 5-Star (2023). The album is preceded by the title track "CEREMONY".KARMA was the best-selling album in South Korea, and the sixth worldwide in 2025. It was certified triple million by the Korea Music Content Association.  Stray Kids earned the Album of the Year award at the 2025 MAMA Awards and Album Daesang at the 40th Golden Disc Awards.
21	3	DEADLINE	MINI ALBUM	2026-02-27	Korean	DEADLINE is the third mini-album by BLACKPINK. It was released on February 27, 2026 with GO serving as the album's title track.
22	3	JUMP	SINGLE	2025-07-11	Korean	“Jump" (stylized as JUMP; Korean: 뛰어) is a single by the South Korean girl group BLACKPINK. Released on July 2025, it marked their first group comeback in nearly three years.  It serves as a pre-release single for their third mini-album, “Deadline”, which was released on February 27, 2026.
23	3	The Girls	OST	2023-08-25	English	"The Girls" was released as part of the official soundtrack of 'BLACKPINK: THE GAME.' Members Jennie and Rosé participated in writing the lyrics.
24	3	BORN PINK	STUDIO	2022-09-16	Korean	Born Pink is the second studio album by BLACKPINK, released on September 16, 2022, by YG Entertainment and Interscope Records.
25	3	Pink Venom	SINGLE	2022-08-19	Korean	"Pink Venom" is the fourth digital single by BLACKPINK. It was released on August 19, 2022, as the pre-release single for the group's second studio album, Born Pink.
26	3	Ready For Love	SINGLE	2022-07-29	Korean	"Ready for Love" is a promotional single by BLACKPINK, in collaboration with the video game PUBG MOBILE. It was released on July 29, 2022 alongside its accompanying music video. The song was first previewed during their in-game concert The Virtual on July 22–23.
27	3	The Album -JP Ver.-	STUDIO	2021-08-03	\N	The Album -JP Ver.- (stylized in allcaps) is the third Japanese full-length album by BLACKPINK (labelled as their first full album). It was released on August 3, 2021.
28	3	BLACKPINK - 2021 'THE SHOW' LIVE	LIVE	2021-06-01	Korean	Blackpink 2021 'The Show' Live is the fourth live album by Blackpink. It was surprise-released on June 1, 2021 and features live versions and performances from BLACKPINK's first online concert, The Show.
29	3	THE ALBUM	STUDIO	2020-10-02	\N	"THE ALBUM" is the first Korean-language studio album (second overall) by South Korean girl group BLACKPINK, released on October 2, 2020, through YG Entertainment and Interscope. The album was released for pre-order on August 28. It was BLACKPINK's first Korean release since Kill This Love" in 2019. For the album, BLACKPINK recorded 8 new songs and worked with a variety of producers, including Teddy, Tommy Brown, R. Tee, Mr. Franks, Ariana Grande, David Guetta, Future Bounce and 24. Written and recorded in isolation during the COVID-19 pandemic, the group stated that the album "shows a more mature part of us through singing not only about love but diverse emotions experienced by girls growing up".The Album generated three singles. "How You Like That" was released as the lead single on June 26, 2020. "Ice Cream" with American singer Selena Gomez was released as the second single on August 28, 2020. "Lovesick Girls" was released as the third single and title track alongside the album on October 2, 2020.
30	3	Ice Cream (with Selena Gomez)	SINGLE	2020-08-28	\N	"Ice Cream" is a song by BLACKPINK and Selena Gomez. It was released on August 28, 2020,  as the second pre-release single from the group's debut studio album, The Album (2020).
31	4	TWICE BEST ALBUM「#BEST 2015-2025」	COMPILATION	\N	Japanese	"TWICE BEST ALBUM「#BEST 2015-2025」" is a compilation album by TWICE. It will be released on August 26, 2026.
32	4	TEN: The Story Goes On	STUDIO	2025-10-10	Korean	TEN: The Story Goes On is the fourth special album by TWICE. It was released on October 10, 2025, to celebrate their 10th anniversary. The album consists of ten tracks, including the title track “ME+YOU” and nine solo tracks previously performed on their “THIS IS FOR” world tour.
33	4	ENEMY	STUDIO	2025-08-27	Japanese	ENEMY is the sixth Japanese full-length album by TWICE. It was released on August 27, 2025 with "ENEMY" serving as the album's title track."ENEMY" and "Like 1" were pre-released on July 30 and August 20, 2025, respectively.
34	4	THIS IS FOR (DELUXE)	REPACKAGE	2025-07-14	Korean	THIS IS FOR (DELUXE) is the deluxe version of TWICE's fourth full album, THIS IS FOR. It was released on July 14, 2025.
35	4	THIS IS FOR	STUDIO	2025-07-11	Korean	THIS IS FOR is the fourth full-length album by TWICE. It was released on July 11, 2025 with "THIS IS FOR" serving as the title track.
36	4	#TWICE5	COMPILATION	2025-05-14	Japanese	#TWICE5 is the fifth Japanese best album by TWICE. It was released on May 14, 2025 with "Talk that Talk (Japanese Ver.)" serving as the album's title track."Talk that Talk (Japanese Ver.)" was pre-released on April 14, 2025.
37	4	Strategy 2.0	SINGLE	2024-12-18	English	"Strategy 2.0" is the fourth English remix single by TWICE. It was released on December 18, 2024 with "Strategy (Version 1.0)" as the single's title track.
38	4	The wish	SINGLE	2024-12-15	Japanese	"The Wish" (stylized as The wish) is the sixth Japanese digital single by TWICE. It was released on December 16, 2024.The song was released in collaboration with Family Mart Japan.
39	4	STRATEGY	MINI ALBUM	2024-12-06	Korean	STRATEGY is the fourteenth mini album by TWICE. It was released on December 6, 2024 with "Strategy (feat. Megan Thee Stallion)" serving as the album's title track.
40	4	DIVE	STUDIO	2024-07-17	Japanese	DIVE is the fifth Japanese full-length album by TWICE. It was released on July 17, 2024 with "DIVE" serving as the album's title track."DIVE" was pre-released on July 10, 2024.
41	5	THE SIN : BLISS	MINI ALBUM	\N	Korean	"THE SIN : BLISS" is the eighthmini album by ENHYPEN. It will be released on August 21, 2026.This new mini album serves as the direct sequel to their previous concept album, "THE SIN : VANISH", which dropped in January 2026.The album continues to expand on ENHYPEN’s signature dark fantasy and vampire narrative. It picks up the storyline from the "Sin" series, following the thematic motifs of taboos, fate, and romance.
42	5	We'll Be Fine	SINGLE	2026-06-29	Japanese	"We'll be fine" is a Japanese digital single by ENHYPEN. It was released on June 28, 2026. Designed in a pop-style aesthetic with ENCHIN, the character representing ENGENE's (the fans) friend, set against a summery light-blue background. The group expressed that they hope Japanese fans feel even closer to them through the track.
43	5	THE SIN : VANISH	MINI ALBUM	2026-01-16	Korean	THE SIN : VANISH is the 7th mini album by ENHYPEN. It was released on January 16th 2026, 2 PM KST.
44	5	Dark Moon: The Blood Altar OST	OST	2026-01-12	\N	DARK MOON: The Altar of the Moon Soundtrack Compilation is an OST album by ENHYPEN. It was released on January 12, 2026, under BELIFT LAB, with “One In A Billion (Japanese Ver.)” serving as the album’s opening theme.
45	5	-YOI-	SINGLE	2025-07-28	\N	"宵 -Yoi-" (stylized as 宵 -YOI-) is the fourth Japanese single by ENHYPEN. It was released on July 28, 2025 with "Shine On Me" serving as the single's title track."Shine On Me" was pre-released on July 4, 2025.
46	5	Shine On Me	SINGLE	2025-07-04	Japanese	"Shine On Me" is the fourth Japanese digital single by ENHYPEN. It was released on July 4, 2025 as the pre-release for their fourth Japanese single "宵 -Yoi-", and serves as the ending theme for Nippon TV's drama "海老だって鯛が釣りたい".
47	5	Demons [The Seasons: Park Bogum's Cantabile]	SINGLE	2025-06-13	\N	"Demons [The Seasons: Cantabile of Park Bo Gum]" (Demons [THE 시즌즈: 박보검의 칸타빌레]) is the third digital single by ENHYPEN. It was released on June 13, 2025. On June 13, 2025, ENHYPEN released a remake of Imagine Dragons's "Demons" for the music talk show The Seasons: Cantabile of Park Bo Gum.
48	5	DESIRE : UNLEASH	MINI ALBUM	2025-06-05	Korean	DESIRE : UNLEASH is the 6th mini album by ENHYPEN released on June 5, 2025 with "Bad Desire (With Or Without You)" serving as the album's title track. The physical album comes in 13 versions: Make, You, Mine, Bath Bomb, Keyring, seven individual Engene versions, and Weverse Album.
49	5	Loose	SINGLE	2025-04-04	\N	ENHYPEN’s Digital Single “Loose” will be released on Friday, April 4, 2025.On the digital cover of ENHYPEN's upcoming single 'Loose':"It's just me and you - I don't wanna waste another second tonight.""I've been waiting to get next to you I can tell how bad you want it too - All this tension, baby let your body loose"
50	5	ROMANCE : UNTOLD -daydream- (JAPAN Edition)	SINGLE	2024-11-24	\N	ENHYPEN 2nd repackaged album ROMANCE : UNTOLD -daydream- (JAPAN Edition)
51	6	REVERXE	STUDIO	2026-01-19	Korean	"Reverxe" is the eighth full-length album by EXO. It will be released on January 19, 2026. The album marks the first release to include member Lay in nearly four years, while members Xiumin, Baekhyun and Chen didnot partake in the album's production or promotions, presumably due to their ongoing legal dispute with SM Entertainment.
52	6	2025 SMTOWN : THE CULTURE, THE FUTURE	STUDIO	2025-02-14	Korean	2025 SMTOWN : The Culture, The Future is the 16th special album by SMTOWN. It was released on February 14, 2025 with "Thank You" serving as the album's title track."Hug" and "Miracle" were pre-released on January 8 and January 22, 2025, respectively.
53	6	EXIST	STUDIO	2023-07-10	\N	"Exist" is the seventh full-length album by EXO. It was released on July 10, 2023 with "Cream Soda" serving as the album's title track."Let Me In" was pre-released on June 12, followed by "Hear Me Out" on June 30.
54	6	Hear Me Out	SINGLE	2023-06-30	Korean	"Hear Me Out" is the sixth digital single by EXO. It was released on June 30, 2023, as the second pre-release single for their seventh full-length album, Exist.
55	6	Let Me In	SINGLE	2023-06-12	\N	Discover Let Me In, the official single from K-pop artist EXO. The album was released on 2023-06-12. The release features 1 tracks, including the title track "Let Me In". Explore the full tracklist, music videos, and concept photos below.
56	6	2022 Winter SMTOWN : SMCU PALACE	STUDIO	2022-12-26	Korean	2022 Winter SMTOWN : SMCU PALACE is the tenth winter album by SM Town. It was released by SM Entertainment on December 26, 2022. The album contains ten tracks that saw various collaborations of the label's artists, with two singles have been released to support the album; "Beautiful Christmas" was released as the album's lead single on December 14, 2022, and "The Cure", released as the second single on January 1, 2023, during the annual online free concert SM Town Live 2023: SMCU Palace at Kwangya.The album features Kangta, BoA, TVXQ!, SUPER JUNIOR, Girls' Generation's Taeyeon and Hyoyeon, SHINee's Onew, Key and Minho, EXO, Red Velvet, NCT's Sungchan and Shotaro, NCT 127, NCT DREAM, WayV, aespa and ScreaM Records's DJs Ginjo, IMLAY, Raiden and Mar Vista.
57	6	2021 Winter SMTOWN : SMCU Express	STUDIO	2021-12-27	Korean	2021 Winter SM Town: SMCU Express (stylized as 2021 Winter SMTOWN : SMCU EXPRESS) is the ninth winter album by SM Town. The studio album was released by SM Entertainment on December 27, 2021, and is available in 13 different versions. It features 10 songs, including two singles off the album, "Dreams Come True" and "Hope from Kwangya". The album marks the first SM Town's special season album release in 10 years after the predecessor 2011 Winter SMTOWN: The Warmest Gift, which was released in December 2011. It is also the first album to feature Kai, Red Velvet, NCT, and Aespa.As part of the SM Town 2022: SMCU Express project, 2021 Winter SM Town: SMCU Express was unveiled as SM Entertainment’s first winter album in a decade, marking their return to the seasonal tradition last seen in 2011.SM Entertainment shared that the record would showcase a wide range of artists under the label, promising unique collaborations and unexpected combinations beyond just the usual group tracks.Ahead of the full album release, a jazz version of “The Promise of H.O.T.” was pre-released on November 26, 2021 through SM Station and later added to the official tracklist on December 24. Shortly after, “Dreams Come True” was unveiled via SM Station on December 20 and went on to serve as the album’s lead single.Pre-orders for the album began on December 10, with the official release scheduled for December 27, 2021.
58	6	Don't Fight The Feeling	MINI ALBUM	2021-06-07	\N	Don't Fight The Feeling is the fifth special album by EXO. It was released on June 7, 2021 with "Don't Fight The Feeling" serving as the album's title track.This is the group's very first comeback since April 2020, Xiumin and D.O. completing their military services on December 6, 2020 and January 25, 2021, respectively and Lay's return from hiatus. Baekhyun and Chanyeol also participated in its recording and jacket shooting before they enlisted on their military services on May 6 and March 29, 2021, respectively.
59	6	EXO PLANET #5 – EXplOration	LIVE	2020-04-21	Korean	EXO Planet #5 –EXplOration– is the fourth live album by EXO. It was released on April 21, 2020.The songs were recorded on their concert days at the Olympic Gymnastics Arena in Seoul, South Korea.
60	6	OBSESSION	STUDIO	2019-11-27	\N	Obsession is the sixth Korean full-length album by EXO. It was released on November 27, 2019 with "Obsession" serving as the album's title track.Obsession is the group's first release without members Xiumin and D.O., who were currently completing their mandatory military service.[2][3] Member Lay also did not participate in the group's comeback.
61	7	Tiny Light	OST	2026-03-04	English	"Tiny Light" is an OST for BEASTARS Final Season Part 2 Ending Theme by SEVENTEEN. It was released on March 4, 2026.
62	7	Where Love Passed	SINGLE	2025-07-14	Japanese	"Where Love Passed" is the fourth Japanese digital single by SEVENTEEN. It was released on July 14, 2025.
63	7	Happy Burstday	STUDIO	2025-05-26	\N	Happy Burstday is the fifth full-length album by SEVENTEEN. It was released on May 26, 2025 to celebrate their 10th anniversary with "Thunder" serving as the album's title track.The album features all 13 members, despite Jeonghan and Wonwoo's ongoing military service.
64	7	Shohikigen	SINGLE	2024-11-27	\N	"Shohikigen" is the 4th Japanese single album by SEVENTEEN. It contains 3 songs with "MAESTRO (Japanese ver.)", "Circles (Japanese ver.)" and "Shohikigen" as the title track.
65	7	Love, Money, Fame (Kenia OS Remix)	SINGLE	2024-11-08	Korean	"Love, Money, Fame (Kenia OS Remix)" is a remix single by SEVENTEEN. It was released on November 8, 2024.
66	7	Love, Money, Fame (Timbaland Remix)	SINGLE	2024-11-01	Korean	"Love, Money, Fame (Timbaland Remix)" is a remix single by SEVENTEEN. It was released on November 1, 2024.
67	7	Love, Money, Fame (Remixes)	SINGLE	2024-10-18	Korean	"Love, Money, Fame (Remixes)" is a remix single by SEVENTEEN. It was released on October 18, 2024.
68	7	SPILL THE FEELS	MINI ALBUM	2024-10-14	Korean	"SPILL THE FEELS" is the 12th mini album released by SEVENTEEN. It was released on October 14, 2024 with the title track "LOVE, MONEY, FAME" featuring DJ Khaled.
69	7	MAESTRO (Orchestra Remix)	SINGLE	2024-05-03	\N	"MAESTRO (Orchestra Remix)" is a remix digital single of SEVENTEEN for the song "MAESTRO," which is the title track of their 1st best album "17 Is Right Here."
70	7	17 Is Right Here	COMPILATION	2024-04-29	Korean	"17 Is Right Here" is the first best album by SEVENTEEN. It contains a total of 33 tracks, including 4 new songs: "Maestro," "LALALI," "Spell," and "Cheers to Youth."
71	8	Velvet Summer	MINI ALBUM	\N	Korean	Velvet Summer is the third summer mini album by Red Velvet. It will be released on August 3, 2026 with "Surfin' Boy" serving as the album's title track.
72	8	Sweet Dreams	SINGLE	2024-08-01	Korean	"Sweet Dreams" is a song by Red Velvet. It was released on August 1, 2024 as part of the Cosmie versions of their 11th mini album Cosmic, to commemorate the group's 10th debut anniversary.
73	8	Cosmic	MINI ALBUM	2024-06-24	Korean	"Cosmic" is the eleventh (labeled as seventh) mini album by Red Velvet. It was released on June 24, 2024 with "Cosmic" serving as the album's title track.The Cosmie version, which was released on August 1, 2024, includes all 6 previously released songs and one new song, "Sweet Dreams", which is the title track of the album.
74	8	Chill Kill	STUDIO	2023-11-13	Korean	"Chill Kill" is the third full-length album by Red Velvet. It was released on November 13, 2023 with "Chill Kill" serving as the album's title track.
75	8	iScreaM Vol.25 : Red Flavor Remix	SINGLE	2023-08-31	Korean	"iScreaM Vol.25 : Red Flavor Remix" is the third remix single by Red Velvet. It was released on August 31, 2023 as the 25th release of the iScreaM project.
76	8	Beautiful Christmas	SINGLE	2022-12-14	Korean	"Beautiful Christmas" is a collaboration digital single by Red Velvet and aespa. It was released on December 14, 2022 as the pre-release for SMTOWN's ninth winter album, 2022 Winter SMTOWN : SMCU Palace.
77	8	The ReVe Festival 2022 - Birthday	MINI ALBUM	2022-11-28	Korean	"The ReVe Festival 2022 - Birthday" is the tenth (labeled as eighth) mini album by Red Velvet. It was released on November 28, 2022, with "Birthday" serving as the album's title track.
78	8	Bloom	STUDIO	2022-04-06	Japanese	"Bloom" is the first Japanese full-length album by Red Velvet. It was released in April 6, 2022 with "WILDSIDE" serving as the album's title track.The song "WILDSIDE" was pre-released on digital platforms on March 28 along with its music video.
79	9	Setsuna Hanabi	SINGLE	\N	Japanese	"Setsuna Hanabi" is a fifth Japanese single by TOMORROW X TOGETHER. It will be released on August 19, 2026.The release features four tracks — three new originals plus an alternate version of the title song.It is TXT's first Japanese comeback in about 10 months, following their 3rd Japanese full album 'Starkissed' last October, which earned a 'Double Platinum' certification from the RIAJ for surpassing 500,000 shipments.
80	9	7TH YEAR: A Moment of Stillness in the Thorns	MINI ALBUM	2026-04-13	Korean	7th Year: A Moment of Stillness in the Thorns is the eighth mini album by TXT. It was released on April 13, 2026 with "Stick With You" serving as the album's title track.
81	9	SSS (Sending Secret Signals) (feat. HYDE)	SINGLE	2026-01-26	Japanese	"SSS (Sending Secret Signals) (feat. HYDE)" is the first Japanese remix single by TXT. It was released on January 26, 2026 and features Japanese rock artist HYDE.
82	9	Starkissed	STUDIO	2025-10-20	\N	Starkissed is the third Japanese full-length album by TXT. It was released on October 20, 2025 with "Can't Stop" serving as the album's title track.
83	9	The Star Chapter: TOGETHER	STUDIO	2025-07-21	\N	The Star Chapter: TOGETHER is the fourth full-length album by TXT. It was released on July 21, 2025 with "Beautiful Strangers" serving as the title track.
84	9	Step by Step	OST	2025-05-26	\N	Step by Step is a Japanese song by TOMORROW X TOGETHER. It serves as the OST for the Japanese television program Mezamashi Doyoubi. It was released on May 26, 2025.
85	9	When The Day Comes	OST	2025-05-11	\N	"When The Day Comes" by TOMORROW X TOGETHER is a soundtrack (OST Part 9) for the drama Hospital Playlist: Wise Resident Life, released on May 11, 2025.
86	9	Love Language	SINGLE	2025-05-02	\N	"Love Language" is the fourth digital single by TXT. It was released on May 2, 2025.
87	9	Melo Movie (OST Part3)	OST	2025-02-14	\N	TOMORROW X TOGETHER released the song "Surfing in the Moonlight" as part of the Original Television Soundtrack for the drama "Melo Movie".
88	9	The Star Chapter: SANCTUARY	MINI ALBUM	2024-11-04	\N	"The Star Chapter: SANCTUARY" is the seventh mini album released by Tomorrow X Together. It contains 6 tracks and was released on November 4, 2024, with the title track "Over the Moon".
89	10	Winter Heptagon	MINI ALBUM	2025-01-20	\N	Winter Heptagon is the 12th mini album by GOT7. It was released on January 20, 2025 with "Python" serving as the album's title track.
90	10	GOT7	MINI ALBUM	2022-05-23	\N	"GOT7" is promoted as the first-ever EP of GOT7. The album's release was highly-anticipated as this was the group's first full group album after leaving JYP Entertainment in 2021. It features six songs, with "NANANA" serving as the title track.
91	10	Encore	SINGLE	2021-02-20	Korean	"Encore" is the fourth digital single by GOT7. It was released on February 20, 2021. It is the group's first release since their departure from JYP Entertainment in January 2021.
92	10	Breath of Love : Last Piece	STUDIO	2020-11-30	\N	"Breath of Love: Last Piece" is the fourth studio album by GOT7. It contains ten songs with "Last Piece" and "Breath" serving as a pre-release single on November 23, 2020.
93	10	Breath	SINGLE	2020-11-23	Korean	Discover Breath, the official single from K-pop artist GOT7. The album was released on 2020-11-23 under JYP Entertainment. The release features 1 tracks, including the title track "Breath". Explore the full tracklist, music videos, and concept photos below.
94	10	DYE	MINI ALBUM	2020-04-20	\N	Dye is the 11th mini album by GOT7. It was released on April 20, 2020 with "Not By The Moon" serving as the album's title track. "Aura" and "Poison" were also performed during their promotions.The physical album comes in 5 versions: A, B, C, D, and E.
95	10	Love Loop ~Sing for U Special Edition~	MINI ALBUM	2019-12-18	\N	Love Loop ~Sing for U Special Edition~ is a repackage of GOT7's fourth Japanese mini album Love Loop. It was released on December 18, 2019. The track "Sing for U" was pre-released on October 21, 2019.The music video for "Sing for U (Memorial Ver.)" was released on December 7, 2019.
96	10	Call My Name	MINI ALBUM	2019-11-04	Korean	Call My Name is the tenth mini album by GOT7. It was released on November 4, 2019 with "You Calling My Name" serving as the album's title track. "Crash & Burn" and "Thursday" were also used during promotions.
97	10	Love Loop	MINI ALBUM	2019-07-31	\N	Love Loop is the fourth Japanese mini album by GOT7. It was released on July 31, 2019, with "Love Loop" serving as the album's title track.The song "Love Loop" was released on June 25, 2019, along with its music video.A repackage titled Love Loop ~Sing for U Special Edition~ was released on December 18, 2019.
98	10	SPINNING TOP : BETWEEN SECURITY & INSECURITY	MINI ALBUM	2019-05-20	\N	Spinning Top : Between Security & Insecurity is the ninth mini album by GOT7. It was released on May 20, 2019 with "Eclipse" serving as the album's title track.The physical release comes in three versions: Security, &, and Insecurity.
99	11	Bad (Japanese Ver.)	SINGLE	\N	Japanese	"Bad (Japanese Ver.)" is the fifth Japanese single by ATEEZ. It will be released on July 29, 2026 with "Bad (Japanese Ver.)" serving as the single's title track.
100	11	BAD (Ofenbach Ver.)	SINGLE	2026-07-06	Korean	"BAD (Ofenbach Ver.)" is the ninth remix single by ATEEZ. It was released on July 6, 2026.
101	11	BAD (James Carter Ver.)	SINGLE	2026-07-02	Korean	"BAD (James Carter Ver.)" is the eighth remix single by ATEEZ. It was released on July 2, 2026.
102	11	BAD (Steve Aoki Ver)	SINGLE	2026-06-30	Korean	"Bad (Steve Aoki Ver.)" is the seventh remix single by ATEEZ. It was released on June 30, 2026.
103	11	Bad (Remix)	SINGLE	2026-06-29	Korean	Bad (Remix) is the third remix album by ATEEZ. It was released on June 29, 2026.
104	11	GOLDEN HOUR : Part.5	MINI ALBUM	2026-06-26	Korean	"GOLDEN HOUR : Part.5" is the fourteenth mini album by ATEEZ. It was released on June 26, 2026 with "BAD" serving as the title track.
105	11	Adrenaline (Remix)	SINGLE	2026-02-09	\N	"Adrenaline (Remix)" is the sixth remix single by Ateez. It was released on February 9, 2026 with "Adrenaline (NO1 Ver.)" serving as the single's title track.
106	11	GOLDEN HOUR: Part.4	MINI ALBUM	2026-02-06	\N	"Golden Hour : Part.4" is the 13th mini album by ATEEZ. It was released on February 6, 2026, “Adrenaline”, serving as the title track.
107	11	Waiting for You (from Last Summer OST)	OST	2025-11-22	\N	Waiting for You (from Last Summer OST) is an OST single by ATEEZ. It was released on November 22, 2025 under YAMYAM Entertainment, with “Waiting for You” serving as the single’s title track.
108	11	Choose	SINGLE	2025-11-17	\N	Choose is a digital single by ATEEZ. It was released on November 17, 2025 under KQ Entertainment, with “Choose” serving as the single’s title track.This release is described as a gift to ATINY, celebrating the long time ATEEZ and their fans have spent together.
109	12	Kiss N Tell	MINI ALBUM	\N	Japanese	Kiss N Tell is the first Japanese mini-album by aespa. It will be released on July 24, 2026 with Kiss N Tell serving as the album's title track.
110	12	LEMONADE (2Spade Remix)	SINGLE	2026-06-03	Korean	On June 3, 2026 aespa released the remix to the track "LEMONADE", remixed by 2Spade.
111	12	LEMONADE (Marlon Hoffstadt Remix)	SINGLE	2026-06-02	Korean	On June 2, 2026 aespa released the remix to the track "LEMONADE". The track is remixed by German producer & DJ, Marlon Hoffstadt.
112	12	LEMONADE (Zedd Remix)	SINGLE	2026-06-01	Korean	On June 1, 2026 aespa released the remix to the track "LEMONADE". The track is remixed by German producer & DJ, Zedd.
113	12	LEMONADE	STUDIO	2026-05-29	Korean	LEMONADE is the second studio album by aespa. It was released on May 29, 2026 with the WDA (Whole Different Animal) (feat. G-Dragon) and LEMONADE serving as the album's title tracks.
114	12	K-POPS! (Music From and Inspired By)	OST	2026-05-29	English	On May 29, 2026, the official soundtrack to the film "K-POPS!" will be released. The singles "Keychain" featuring Aespa and "Aftertaste" featuring DEAN were released on February 27 and May 8 respectively.The soundtrack also features artists Crush, NMIXX, Hongjoong of ATEEZ, Jay Park, LNGSHOT, Chungha, Soyeon of i-dle, Joshua of SEVENTEEN, JO1, Kevin Woo and G-Dragon.The film is directed, written and produced by Anderson .Paak, who also stars in the project.
115	12	WDA (Whole Different Animal)	SINGLE	2026-05-11	Korean	"WDA (Whole Different Animal)" is the ninth digital single by aespa. It was released on May 11, 2026 and features G-Dragon. It serves as the pre-release single for the group's second full-length album, "Lemonade".
116	12	Attitude	SINGLE	2026-03-06	Japanese	"Attitude" is the first Japanese digital single by aespa. It was released on March 6, 2026 as the opening theme song for the anime Kill Blue.
117	12	Keychain	SINGLE	2026-02-27	English	"Keychain" is an OST by aespa and Anderson .Paak. It was released on February 27, 2026 as part of the soundtrack for the movie K-Pops!.
118	12	SYNK : aeXIS LINE	SINGLE	2025-11-17	Korean	"SYNK : aeXIS LINE" is the second special digital single by aespa. It was released on November 17, 2025.
119	13	Motto (Remixes)	SINGLE	2026-05-22	Korean	"Motto (Remixes)" is a remix single by ITZY. It was released on May 22, 2026.
120	13	Motto	MINI ALBUM	2026-05-18	Korean	Motto is the twelfth mini-album by ITZY. It was released on May 18, 2026 with Motto serving as the album's title track.
121	13	Tunnel Vision (Remixes)	SINGLE	2025-11-14	\N	"Tunnel Vision (Remixes)" is the second remix single by ITZY. It was released on November 14, 2025.
122	13	Tunnel Vision	MINI ALBUM	2025-11-10	Korean	"Tunnel Vision" is the 11th EP by ITZY, and it was released on November 10th 2025 with Tunnel Vision as title track.
123	13	Collector	STUDIO	2025-10-08	Japanese	"Collector" is the second Japanese full-length album by ITZY. It was released on October 8, 2025.
124	13	Girls Will Be Girls (Remixes)	SINGLE	2025-06-13	\N	"Girls Will Be Girls (Remixes)" is the first remix single by ITZY. It was released on June 13, 2025.
125	13	Girls Will Be Girls	MINI ALBUM	2025-06-09	Korean	Girls Will Be Girls is the 10th mini album by ITZY.
126	13	Gold (English Ver.)	SINGLE	2024-12-25	\N	"Gold (English Ver.)" is the fourth English digital single by ITZY. It was released on October 25, 2024 with "Gold (English Ver.)" and "Imaginary Friend (English Ver.)" serving as the single's double title tracks.
127	13	GOLD	MINI ALBUM	2024-10-15	\N	"Gold" is a mini album released by ITZY. It was released on October 15, 2024.
128	13	Algorhythm	SINGLE	2024-05-15	Japanese	"Algorhythm" is the third Japanese single album by ITZY. It was released on May 15, 2024, with "Algorhythm" serving as the single's title track.The b-side track "No Biggie" was pre-released on May 1, 2024.
129	14	K-POP ScreaM 2	EP	2025-04-11	Korean	K-POP ScreaM 2 is the third remix EP by ScreaM Records. It was released on April 11, 2025 with "Walk (Arkins Remix)" serving as the album's title track. The album is comprised of nine remixes of songs by Aespa & NCT 127.
130	14	K-POP ScreaM 1	EP	2024-12-11	Korean	K-POP ScreaM 1 is the second remix EP by ScreaM Records. It was released on December 11, 2024 with "Show! Show! Show! (duco Remix)" and "Whiplash (monotostereo Remix)" serving as the album's double title tracks. The album consists of 13 remixes of songs by Girls' Generation, Aespa, RIIZE, NCT, Kai & Taeyeon.
131	14	WALK	STUDIO	2024-07-15	\N	WALK (삐그덕) is the 6th studio album of NCT 127. Released on July 15, 2024, it contains eleven songs together with the title track of the same name.
132	14	Colors	SINGLE	2024-05-23	Japanese	Discover Colors, the official single from K-pop artist NCT 127. The album was released on 2024-05-23 under SM Entertainment. The release features 0 tracks, including the title track "Colors". Explore the full tracklist, music videos, and concept photos below.
133	14	Be There For Me	SINGLE	2023-12-22	\N	"Be There For Me" is the first special single by NCT 127. It was released on December 22, 2023 with "Be There For Me" serving as title track.
134	14	Fact Check - The 5th Album	STUDIO	2023-10-06	\N	"Fact Check" is the 5th studio album of NCT 127. It contains nine songs, with "Fact Check" serving as the title track.
135	14	Ay-Yo	REPACKAGE	2023-01-30	\N	"Ay-Yo" is the fourth album repackage by NCT 127. It contains fifteen songs, with "Ay-Yo" serving as the title track.
136	14	2 Baddies	STUDIO	2022-09-16	\N	"2 Baddies" is the fourth studio album of NCT127. It contains twelve songs, with "2 Baddies" serving as the title track.
137	15	ICONIC BY MISTAKE	SINGLE	2026-06-11	English	ICONIC BY MISTAKE is a collaboration between LE SSERAFIM, ILLIT, & KATSEYE. It was released on June 11, 2026.
138	15	BOOMPALA (feat. GURU RANDHAWA)	SINGLE	2026-06-06	English	"BOOMPALA (feat. GURU RANDHAWA)" is the remix single by LE SSERAFIM. It was released on June 06, 2026.
139	15	BOOMPALA (feat. SANTOS BRAVOS)	SINGLE	2026-06-05	English	"BOOMPALA (feat. SANTOS BRAVOS)" is the remix single by LE SSERAFIM. It was released on June 05, 2026.
140	15	Boompala (Champions Remix)	SINGLE	2026-06-03	English	"Boompala (Champions Remix)" is the eleventh English remix single by LE SSERAFIM. It was released on June 3, 2026.
141	15	CELEBRATION (Supergirl Version)	OST	2026-05-31	Korean	"CELEBRATION (Supergirl Version)" is the second OST by LE SSERAFIM. It was released on May 31, 2026 as a collaboration with DC Studios for the movie, Supergirl.
142	15	BOOMPALA (LE SSERAFIM Package)	SINGLE	2026-05-25	English	"BOOMPALA (LE SSERAFIM Package)" is the tenth English remix single by LE SSERAFIM. It was released on May 25, 2026.
143	15	Boompala (Remixes)	SINGLE	2026-05-23	English	"Boompala (Remixes)" is the ninth English remix single by LE SSERAFIM. It was released on May 23, 2026 with "Boompala" serving as the album's title track.
144	15	PUREFLOW pt.1	STUDIO	2026-05-22	Korean	"PUREFLOW" pt.1 is the second studio album by LE SSERAFIM. It was released on May 22, 2026 with "Celebration" and "Boompala" serving as the album's double title tracks."CELEBRATION" was pre-released on April 24, 2026.
145	15	CELEBRATION (Sara Landry Remix)	SINGLE	2026-05-06	Korean	"CELEBRATION (Sara Landry Remix)" is the remix single by LE SSERAFIM. It was released on May 06, 2026.
146	15	CELEBRATION (Remixes)	SINGLE	2026-04-25	Korean	"CELEBRATION (Remixes)" is the seventh remix single by LE SSERAFIM. It was released on April 25, 2026.
147	16	GREENGREEN	MINI ALBUM	2026-05-04	Korean	Greengreen (stylized in all caps) is the second EP by CORTIS. It was released on May 4, 2026 with the title track "TNT"."REDRED" was pre-released on April 20, 2026, with an accompanying music video.The music video for the track "ACAI" was released on May 11.
148	16	REDRED	SINGLE	2026-04-20	Korean	"REDRED" is the second digital single by CORTIS. It was released on April 20, 2026 as a pre-release for their second EP, GREENGREEN.
149	16	Mention Me	SINGLE	2026-02-13	English	"Mention Me" is a single by CORTIS for the 2026 animated sports film "GOAT". It was released on February 13.
150	16	COLOR OUTSIDE THE LINES	MINI ALBUM	2025-09-08	Korean	CORTIS debut album "COLOR OUTSIDE THE LINES" was released on September 8th 6PM KST with "What You Want" serving as the title track.
151	16	What You Want (feat. Teezo Touchdown)	SINGLE	2025-08-22	\N	The English Version of What You Want featuring American Rapper Teezo Touchdown was released on August 22,2025.
152	16	What You Want	SINGLE	2025-08-18	\N	CORTIS digital single 'What You Want' is a pre-release of their title track from their debut album 'COLOUR OUTSIDE THE LINES'.
153	17	SUGAR HONEY ICE TEA	SINGLE	2026-06-08	Korean	"SUGAR HONEY ICE TEA" is the fourth digital single by BABYMONSTER. It was released on June 8, 2026.
154	17	CHOOM	MINI ALBUM	2026-05-04	Korean	"CHOOM" is the third mini album by BABYMONSTER. It was released on May 4, 2026. Rami did not participate in this comeback as she is still on hiatus.The music video for "I LIKE IT" was released on June 6, 2026.
155	17	We Go Up	MINI ALBUM	2025-10-10	Korean	We Go Up (stylized in all caps) is the second mini album by South Korean girl group Babymonster. It was released on October 10, 2025, and consists of four tracks, including the title track of the same name.
156	17	2025 BABYMONSTER 1st World Tour - HELLO MONSTERS - IN JAPAN	LIVE	2025-09-14	Korean	2025 BABYMONSTER 1st World Tour <Hello Monsters> in Japan, is the first Japanese live album by BABYMONSTER. It was released on September 14, 2025. The recordings for this album were from their concert at K-Arena Yokohama in Japan on, April 13, 2025.
157	17	HOT SAUCE	SINGLE	2025-07-01	English	"HOT SAUCE" is the second digital single by BABYMONSTER. It was released on July 1, 2025.
158	17	Ghost	OST	2025-05-07	Japanese	"Ghost" is the first Japanese OST by BABYMONSTER. It was released on May 7, 2025 as the theme song of the film "見える子ちゃん (Mieruko-chan), a live-action adaptation based on the manga series of the same name.
159	17	DRIP	STUDIO	2024-11-01	Korean	"Drip" is the first full album by BABYMONSTER. It was released on November 1, 2024, with "Drip" serving as the title track.
160	17	Batter Up (JP Ver.)	SINGLE	2024-08-16	Japanese	"Batter Up (JP Ver.)" is the first Japanese single by BABYMONSTER.
161	17	FOREVER	SINGLE	2024-07-01	Korean	"FOREVER" is a digital single by BABYMONSTER.
162	17	BABYMONS7ER	MINI ALBUM	2024-04-01	Korean	"BABYMONS7ER" is the first mini album by BABYMONSTER. It was released on April 1, 2024 with "Sheesh" serving as the album's title track.
163	18	I Got Your Back	SINGLE	\N	Japanese	"I Got Your Back" is the second Japanese single by ILLIT. It will be released on July 26, 2026.
164	18	MAMIHLAPINATAPAI	MINI ALBUM	2026-04-30	Korean	"MAMIHLAPINATAPAI"  (pronounced mah-mee-lah-pee-nah-tah-pie) is the fourth mini album by ILLIT. It was released on April 30, 2026 with "It's Me" serving as the album's title track, the album's name is derived is from the Yaghan word from Tierra del Fuego, listed in The Guinness Book of World Records as the "most succinct word", and is considered one of the hardest words to translate.It has been translated as "a look that without words is shared by two people who want to initiate something, but that neither will start" or "looking at each other hoping that the other will offer to do something which both parties desire but are unwilling to do".
165	18	Bubee (Korean Ver.)	SINGLE	2026-04-13	Korean	On April 13, 2026 ILLIT released the Korean version of their song "Bubee".
166	18	Bubee	SINGLE	2026-04-06	Japanese	"Bubee" is the fourth Japanese digital single by ILLIT. It was released on April 6, 2026 as the opening theme for the TV anime Magical Sisters LuluttoLilly.
167	18	Sunday Morning	SINGLE	2026-01-13	\N	"Sunday Morning" is the third Japanese digital single by ILLIT. It was released on January 13, 2026 as the opening theme for the TV anime 'Tis Time for "Torture," Princess Season 2. It serves as a pre release for the single 'I Got Your Back'.
168	18	Not Cute Anymore (Holiday Remixes)	SINGLE	2025-12-19	Korean	"Not Cute Anymore (Holiday Remixes)" is the third remix single by ILLIT. It was released on December 19, 2025 and consists of remixes of "Not Cute Anymore" from the group's first single album, Not Cute Anymore.
169	18	All For You, 2027	SINGLE	2025-12-16	Korean	All For You, 2027, is the first promotional single by ILLIT. This song was originally made for MegaStudyEdu's, 2027 MEGAPASS on November 3, 2025.  It was released as a single album on December 16, 2025.
170	18	Not Cute Anymore	SINGLE	2025-11-24	Korean	"Not Cute Anymore" is the first Korean single album by ILLIT. It was released on November 24, 2025.
171	18	Love Smile	OST	2025-11-15	Korean	Love Smile is a song by ILLIT's Yunah and Minju. It serves as an OST for the original soundtrack for Last Summer. It was released on November 15, 2025.
172	19	Unfold	STUDIO	2026-04-03	English	Unfold is the third English studio album by MONSTA X. It was released on April 3, 2026 with "Heal" serving as the album's title track.
173	19	growing pains	SINGLE	2026-02-06	English	"Growing Pains" (stylized in all lower caps) is the eighth English digital single by MONSTA X. It was released on February 6, 2026.The track was later included in their third English studio album, Unfold, released in April of the same year.
174	19	Baby Blue	SINGLE	2025-11-14	English	"Baby Blue" is the seventh English digital single by MONSTA X. It was released on November 14, 2025.
175	19	N the Front (H.ONE Remix)	SINGLE	2025-09-05	\N	“N the Front (H.ONE Remix)” is a remix of Monsta X’s N the Front from The X, released on September 5, 2025.
176	19	The X	MINI ALBUM	2025-09-01	Korean	The X is the 13th mini album by MONSTA X. It was released on September 1, 2025 with "N The Front" serving as the album's title track."Do What I Want" was pre-released on August 18, 2025.
177	19	Do What I Want	SINGLE	2025-08-18	\N	“Do What I Want" is a pre-release track, issued on August 18, 2025. It will serve as the opening track on the group’s upcoming mini album The X, scheduled for release on September 1, 2025.
178	19	Beautiful Liar / GAMBLER (JAPAN SPECIAL EDITION)	SINGLE	2025-05-28	\N	"Beautiful Liar / Gambler (Japan Special Edition)" is the second Japanese digital single by MONSTA X. It was released on May 28, 2025.
179	19	NOW PROJECT vol.1	STUDIO	2025-05-14	\N	Now Project Vol.1 (stylized as NOW PROJECT vol.1) is the first remake album (labeled as a digital album) by MONSTA X. It was released on May 14, 2025 to celebrate the group's 10th anniversary with "Rush Hour (Rerecorded)", "Love (Rerecorded)" and "Beautiful Liar (Rerecorded)" serving as the album's triple title tracks.
180	19	SWING	SINGLE	2023-03-16	\N	SWING is a collab track featuring Monsta X, Play-N-Skillz, Lil Jon, Bun B, and Symba for the 2023 World Baseball Classics (WBC). It was released digitally on March 16, 2023.
214	23	Lion Heart	STUDIO	2015-08-18	\N	”Lion Heart” is the 5th album by Girls’ Generation. It was released on August 18, 2015.
181	19	Reason	MINI ALBUM	2023-01-09	\N	Reason is the 12th mini album by MONSTA X. It was released on January 9, 2023 with "Beautiful Liar" serving as the album's title track. This release marks the last appearance of Minhyuk before enlisting in the military.
182	20	We made	MINI ALBUM	2026-07-06	Korean	"We made" is the 9th mini-album by i-dle. It was released on July 6, 2026 with "Gimme Dat Love" serving as the album's title track.
183	20	Crow	SINGLE	2026-06-15	Korean	"Crow" is a digital single by i-dle. It is a pre-release for their 9th Mini Album 'We Made'. It was released on June 15, 2026.
184	20	Hide and Seek	SINGLE	2026-04-22	Japanese	"Hide and Seek" is the first Japanese digital single by i-dle. It was released on April 22, 2026. It will be the opening theme for the TV Asahi's series Gals Can't Be Kind to Otaku!?.
185	20	Mono	SINGLE	2026-01-27	Korean	"Mono" is the sixth digital single by i-dle. It was released on January 27, 2026.
186	20	Genie, Make a Wish - OST Part 3	OST	2025-10-03	Korean	i-dle(Soyeon, Yuqi) sang 'GAME' as part of OST of the drama 'Genie, Make a Wish'.
187	20	I-dle	MINI ALBUM	2025-10-03	\N	"i-dle" is the first Japanese EP by i-dle. It was released on October 3, 2025 with "どうしよっかな" serving as the album's title track.
188	20	'Solo Leveling:ARISE' (Original Soundtrack)	OST	2025-07-03	\N	"'Solo Leveling:ARISE' (Original Soundtrack)" is an OST by i-dle that is a part of a collaboration between the group and the video game "Solo Leveling:ARISE".
189	20	We Are	MINI ALBUM	2025-05-19	Korean	"We Are" is the eighth mini album by i-dle. It was released on May 19, 2025 with "Good Thing" serving as the album's title track.
190	20	We are i-dle	MINI ALBUM	2025-05-02	\N	Released in May 2, 2025, "We are i-dle" is i-dle's 1st Special Mini Album.
191	20	I SWAY	MINI ALBUM	2024-07-08	\N	“I SWAY” is the 7th mini album by (G)I-DLE, serving "KLAXON" as its title track. It was released on July 8, 2024.
192	21	Atmos	MINI ALBUM	2026-06-01	Korean	"Atmos" is the sixth mini album by SHINee. It was released on June 1, 2026.
193	21	Poet | Artist	SINGLE	2025-05-25	Korean	Poet | Artist is the first single album by South Korean boy band SHINee. It was released on May 25, 2025, through SM Entertainment, to mark the group's 17th anniversary. The album was interpreted by music critics as a tribute to their late bandmate Jonghyun. It is also seen in the album title as it references the final studio album released posthumously by Jonghyun.It consists of two tracks, including the lead single, "Poet | Artist", which was written by Jonghyun.  The song also features his vocals in the bridge taken from the guide version he left behind.
194	21	HARD	STUDIO	2023-06-26	\N	"HARD" is the 8th full-length album of SHINee. It contains ten songs, with "Hard" serving as the title track.
195	21	Superstar	MINI ALBUM	2021-06-28	Japanese	"Superstar" is the first Japanese mini-album by the South Korean boy group SHINee. Released digitally on June 28, 2021, and physically on July 28, 2021, it marked the group's first original Japanese release in approximately three years. The album has 5 tracks with "Superstar" serving as the album's title track.
196	21	Atlantis	STUDIO	2021-04-12	\N	"Atlantis" is the repackage of SHINee's seventh full-length album, "Don't Call Me". It contains twelve songs, including the title track, "Atlantis".
197	21	iScreaM, Vol.7	SINGLE	2021-03-27	\N	"iScreaM, Vol.7" is a digital single album that features remixes for SHINee's "Don't Call Me."
198	21	Don't Call Me	STUDIO	2021-02-22	\N	"Don't Call Me" is the 7th full-length album by SHINee. It has 9 songs, with "Don't Call Me" serving as the title track. The song "Heart Attack" also served as their follow-up single.Moreover, this also marks the first comeback of the group after Minho, Onew, and Key finished their military services.
199	21	'The Story of Light' Epilogue	STUDIO	2018-09-10	\N	'The Story of Light' Epilogue is the second compilation album and a repackage of SHINee's sixth full-length album The Story of Light. It was released on September 10, 2018 with "Countless" serving as the album's title track.The album combines all 15 songs from EP.1, EP.2, EP.3 and a new track titled "Countless".
200	22	LUCID DREAM (Taku Takahashi Remix)	SINGLE	2026-07-01	Japanese	"LUCID DREAM (Taku Takahashi Remix)" is a remix single by IVE. It was released on July 1, 2026.
201	22	Lucid Dream	EP	2026-05-27	Japanese	"Lucid Dream" is the fourth Japanese EP by IVE. It was released on May 27, 2026 with "Lucid Dream" serving as the album's title track. "Fashion" was pre-released on April 3, 2026.
202	22	Fashion	SINGLE	2026-04-03	Japanese	"Fashion" is the fourth Japanese digital single by IVE. It was released on April 3, 2026 as the campaign song for App Store's "Every Step with App Store" and the pre-release single for their fourth Japanese EP "Lucid Dream".
203	22	REVIVE+	STUDIO	2026-02-23	Korean	"REVIVE+" is the second studio album by IVE. It was released on February 23, 2026, with “BLACKHOLE” and the pre-release song "BANG BANG" serving as the title tracks.
204	22	BANG BANG	SINGLE	2026-02-09	English	BANG BANG is the pre-release single for IVE's upcoming album, REVIVE+. It was released on February 9, 2026.
205	22	IVE SECRET	MINI ALBUM	2025-08-25	\N	"IVE Secret" is the fourth EP by IVE. It was released on August 25, 2025 with "XOXZ" serving as the album's title track.
206	22	Be Alright	MINI ALBUM	2025-07-30	Japanese	Be Alright is the third Japanese EP by IVE. It was released on July 30, 2025 with "Be Alright" serving as the album's title track."Be Alright" was pre-released on July 16, 2025.
207	22	DARE ME	OST	2025-04-21	Japanese	"Dare Me" is the first Japanese OST single by IVE. It was released on April 21, 2025, as the opening song for the NTV drama Damemane! - We'll Manage a Useless Talent. It is included in their third Japanese EP.
208	22	IVE EMPATHY	MINI ALBUM	2025-02-03	Korean	"IVE Empathy" is the third EP by IVE. It was released on February 3, 2025 with "Rebel Heart" and "Attitude" serving as the album's double title tracks. "Rebel Heart" was pre-released on January 13, 2025.
209	22	REBEL HEART	SINGLE	2025-01-13	\N	"Rebel Heart" is the sixth digital single by IVE. It was released on January 13, 2025 as the pre-release single for their third EP, IVE Empathy.
210	23	iScreaM Vol.19 : Forever 1 Remixes	SINGLE	2022-11-17	Korean	"iScreaM Vol.19 : Forever 1 Remixes" is the first remix single by Girls' Generation. It was released on November 17, 2022 as the 19th release of the iScreaM project.
211	23	Forever 1	STUDIO	2022-08-05	Korean	"Forever 1" is the highly-anticipated seventh full album of Girls' Generation. It is the group's first music release in five years.
212	23	Holiday Night	STUDIO	2017-08-04	\N	”Holiday Night” is the 6th full album by Girls’ Generation, released in time of the group’s 10th anniversary on August 4th, 2017.
213	23	Sailing (0805) - SM STATION	SINGLE	2016-08-05	\N	”Sailing (0805)” is an SM Station single by Girls’ Generation. It was released to commemorate their 9th anniversary.
215	23	Party	SINGLE	2015-07-07	\N	”Party” is the pre-release single for Girls’ Generation’s 5th album ”Lion Heart”.
216	23	Catch Me If You Can	SINGLE	2015-04-10	\N	”Catch Me if You Can” is the Korean version of Girls’ Generation’s 9th Japanese single of the same name. It was released on April 10th, 2015.
217	23	Mr. Mr.	MINI ALBUM	2014-02-24	\N	”Mr. Mr.” is the 4th Mini Album by Girls’ Generation. It was released on February 14, 2014.
218	24	Spring Breeze, Again (Original Soundtrack from Wanna One Go: Back to Base)	SINGLE	2026-05-20	Korean	On May 20, 2026, Wanna One released the single "Spring Breeze, Again" as the second OST from Mnet Plus original reality show 'WANNA ONE GO: Back to Base'. The track's title is a direct callback to Wanna One's 2018 song, "Spring Breeze", from their studio album "1¹¹=1 (Power Of Destiny)" released before their disbandment the same year.Ha Sung Woon participated in both writing and composing the song, while Park Woo Jin contributed to the lyrics.
219	24	WE WANNA GO (Original Soundtrack from Wanna One Go: Back to Base)	SINGLE	2026-05-06	Korean	"WE WANNA GO" is the theme song for the Mnet Plus original reality show 'WANNA ONE GO: Back to Base'.
220	24	B-Side	SINGLE	2022-01-27	\N	"B-Side" is the second digital single by Wanna One. It was released on January 27, 2022.The single is the third and final part of their "Beautiful" series, which began with "Beautiful", released in 2017, and "Beautiful (Part Ⅱ)", released in 2018.
221	24	1÷x=1 (Undivided)	MINI ALBUM	2018-06-04	\N	1÷x=1 (Undivided) is the first special album by Wanna One. It was released on June 4, 2018 with "Light" serving as the album's title track.
222	24	0+1=1 (I Promise You)	MINI ALBUM	2018-03-19	\N	0+1=1 (I Promise You) is the second mini album by Wanna One. It was released on March 19, 2018 with "Boomerang" serving as the album's title track. The song "I.P.U." was pre-released on March 5."Boomerang" and "Gold" were leaked online on March 14.
223	24	1-1=0 (NOTHING WITHOUT YOU)	REPACKAGE	2017-11-13	Korean	1-1=0 (Nothing Without You) is a repackage of Wanna One's debut mini-album 1X1=1 (To Be One). It was released on November 13, 2017 with "Beautiful" serving as the album's title track. This was the group's only repackage album before their disbandment.
224	24	1X1=1 (To Be One)	MINI ALBUM	2017-08-07	Korean	1X1=1 (To Be One) is the debut mini album by Wanna One. It was released on August 7, 2017 with "Energetic" serving as the album's title track. The title track was chosen through a fan voting event that ran from July 17 to 27 with the two options being "Burn It Up" and "Energetic".
225	25	Supernatural	SINGLE	2024-06-21	Japanese	“Supernatural" is the debut Japanese single by NewJeans, released on 21 June 2024. It is a double single that also includes the B-side "Right Now" and instrumental versions of both tracks. Produced by 250, "Supernatural" contains an interpolation of a section from the 2009 track "Back of My Mind" by Manami and songwriter Pharrell Williams.
226	25	How Sweet	SINGLE	2024-05-24	Korean	"How Sweet" is the second digital single by NewJeans. It contains two songs, "How Sweet" and "Bubble Gum," together with their instrumental tracks.The music video for "Bubble Gum" was pre-released on April 27th, 2024.
227	25	NJWMX	STUDIO	2023-12-19	Korean	"NJWMX" is the first remix album by NewJeans. It was released on December 19, 2023.
228	25	NewJeans X MY DEMON	OST	2023-11-24	\N	NewJeans released their own rendition of the classic hit song "Our Night is more beautiful than your Day" as part of the original soundtrack of the drama "My Demon," starring Song Kang and Kim Yoo Jung.
229	25	GODS	SINGLE	2023-10-04	\N	NewJeans' October 4th release of GODS for the 2023 League Of Legends World Cup named them as the first K-pop group to feature in LoL's championship anthem.
230	25	A Time Called You OST	OST	2023-09-01	Korean	NewJeans released their own rendition of the song "Beautiful Restriction" (Original by Kim Jong So) as part of the original television soundtrack of the Netflix series, "A Time Called You."
231	25	Get Up	MINI ALBUM	2023-07-21	Korean	"Get Up" is the second EP of NewJeans. It contains six songs, with "Super Shy," "Cool With You," and "ETA" serving as triple title tracks. The songs "New Jeans" and "Super Shy" were pre-released on July 7th. Meanwhile, the music video for "Cool With You" was released on July 20th.
232	25	NewJeans 'Super Shy'	SINGLE	2023-07-07	Korean	"NewJeans 'Super Shy'" is a pre-release single from NewJeans second EP "Get Up." The single contains the b-side tracks "New Jeans" and "Super Shy."
233	25	Zero (JID Remix)	SINGLE	2023-06-21	\N	"Zero (JID Remix)" is a digital single for the Coca-Cola campaign.
234	25	Be Who You Are (Real Magic)	SINGLE	2023-05-31	\N	Be Who You Are (Real Magic) is a collaboration single between John Batiste, JID, Camilo, and NewJeans
235	26	Golden Age - The 4th Album	STUDIO	2023-08-28	\N	"Golden Age" is the 4th studio album of NCT, which was released through the Project NCT 2023. It was released on the 28th of August 2023. The album contains a total of ten songs, with "Baggy Jeans" and "Golden Age" serving as the dual title track.
236	26	Universe - The 3rd Album	STUDIO	2021-12-14	\N	Universe is the third full-length album by NCT. It was released on December 14, 2021 as part of their large-scale project "NCT 2021". "Universe (Let's Play Ball)" and "Beautiful" serve as the album's double title tracks.The song "Universe (Let's Play Ball)" was pre-released on December 10, 2021.Universe is the last NCT album to feature members Shotaro and Sungchan who left the group in May 2023 to join SM Entertainment's new boy group.
237	26	iScreaM Vol6 : Make A Wish / 90's Love Remix	SINGLE	2020-12-17	\N	"iScreaM Vol6 : Make A Wish / 90's Love Remix" is a remix single by NCT, through the iScreaM Project. It was released on the 17th of December 2020. "Make A Wish (Birthday Song) [Wuki Remix]" serving as the title track.
238	26	RESONANCE	SINGLE	2020-12-05	\N	"RESONANCE" is a digital single released as the last part of NCT's large-scale "NCT 2020" project. The song is a remix of the album's 4 title tracks: "Make A Wish (Birthday Song)", "90's Love", "Work It", and "Raise The Roof"
239	26	NCT RESONANCE Pt.2	STUDIO	2020-11-23	\N	"NCT RESONANCE Pt.2" is the second part of NCT's second full-length album. It was released on the 23rd of November 2020. It has 21 songs, with "90's Love" and "Work It" serving as the double title track. The physical album has two versions: Departure and Arrival
240	26	NCT RESONANCE Pt.1	STUDIO	2020-10-12	\N	"NCT RESONANCE Pt.1" is the 2nd album by NCT. It was released on the 12th of October 2020. "Make A Wish (Birthday Song)" serving as the title track by NCT U.
241	26	NCT 2018 EMPATHY	STUDIO	2018-03-14	\N	“NCT 2018 EMPATHY” is the first full-length album by NCT. It was released on March 14, 2018. The physical album comes in two versions: Reality and Dream.
242	27	WILD	EP	\N	English	"WILD" is the 3rd EP of KATSEYE. It will be released on August 14, 2026.
275	30	Mexe	SINGLE	2025-08-22	English	"Mexe" is an English collaboration digital single by Brazilian singer-songwriter Pabllo Vittar and NMIXX. It was released on August 21, 2025 (Brazilian Time)...August 22nd (9am KST time).
243	27	Pinky Up: The Remixes	MINI ALBUM	2026-06-05	English	"Pinky Up: The Remixes" is the second remix album by KATSEYE. It was released on June 5, 2026 with "Pinky Up (Sunset remix)" serving as the album's title track. It consists of remixes of "Pinky Up" from the group's third EP Wild.
244	27	PINKY UP	SINGLE	2026-04-09	English	"Pinky Up" is the sixth single by KATSEYE. It was released on April 9, 2026.
245	27	Internet Girl	SINGLE	2026-01-02	English	"Internet Girl" is a digital single by KATSEYE. It was released on January 2, 2026.
246	27	M.I.A (VALORANT Game Changers Ver.)	OST	2025-11-11	English	On November 11, 2025 KATSEYE in partnership with Valorant, released the anthem for the 2025 Game Changers Championship. The song is a reimagined version of their track "M.I.A.".
247	27	BEAUTIFUL CHAOS: The Remixes	MINI ALBUM	2025-09-05	English	"BEAUTIFUL CHAOS: The Remixes" is a remix EP by KATSEYE. It was released on September 5, 2025.
248	27	Gabriela (Young Miko Remix)	SINGLE	2025-08-08	English	"Gabriela (Young Miko Remix)" is a remix featuring singer Young Miko for the single Gabriela.
249	27	Monster High x KATSEYE - Fright Song	OST	2025-07-18	English	"Fright Song" is a song released by KATSEYE as a collaboration with the Monster High franchise on July 18, 2025.
250	27	Time Lapse	OST	2025-07-06	English	"Time Lapse" is an OST by KATSEYE and is to be featured in A  Korean Drama, "Good Boy". It was released on July 6th, 2025.
251	28	Love Playlist 4 Part.1	OST	2019-07-17	\N	Love Playlist 4 Part.1 is an OST by EXO-CBX for the Korean web drama Love Playlist 4. It was released on July 17, 2019 under PLAYLIST, with “Be My Love” serving as the title track. The release includes an instrumental version of the song.
252	28	Paper Cuts	SINGLE	2019-04-12	\N	"Paper Cuts" is the first Japanese digital single by EXO-CBX. It was released on April 12, 2019.
253	28	MAGIC	STUDIO	2018-05-09	Japanese	Magic (stylized in all caps) is the first Japanese studio album by EXO-CBX, the sub-unit of the South Korean-Chinese boy group EXO. It was released on May 9, 2018. The album contains eleven tracks, including the lead single "Horololo" and a solo track for each member.The album debuted at #3 on the Oricon Weekly Albums chart with 41,173 copies sold during the first week.
254	28	Beautiful World	SINGLE	2018-04-22	\N	"Beautiful World" is the first promotional single by EXO-CBX. It was released on April 22, 2018.This single is the result of a collaboration between Hyundai Motors and EXO-CBX for the advertisement of the Hyundai Kona Electric car. The song is a remake of a Lee Sun Hee’s song.The music video came out on April 30, 2020.
255	28	Blooming Days	MINI ALBUM	2018-04-10	Korean	Blooming Days is the second mini album by EXO-CBX. It was released on April 10, 2018, with "Blooming Day" serving as the album's title track.
256	28	Live OST Part.1	OST	2018-03-24	\N	Live OST Part.1 is an OST by EXO-CBX for the Korean drama Live. It was released on March 24, 2018 under Beyond Music, with “Someone Like You” serving as the title track. The release includes an instrumental version of the song.
257	28	Final Life: Even if You Disappear Tomorrow OST PT. 1	OST	2017-11-02	\N	“Cry” is a song / OST by EXO-CBX for the Japanese drama Final Life: Even if You Disappear Tomorrow. It was released on November 2, 2017 as part of the drama’s official soundtrack, with “Cry” serving as the featured track performed by the sub-unit. The song was released under EMI Records. The track was later included as part of EXO-CBX’s Japanese activities around their album Magic.
258	28	It's Running Time	OST	2017-07-29	\N	"It's Running Time!" is a digital single by EXO-CBX. It was released on July 29, 2017 as the theme song of the animated show Running Man, a 24-episodes animated version of the reality show of the same name.
259	28	GIRLS	EP	2017-05-24	Japanese	GIRLS is the debut Japanese EP by EXO-CBX. It was released on May 24, 2017. The EP features seven tracks in total, including the Japanese version of their debut Korean single "Hey Mama!".
260	28	CRUSH U (with Yoonsang)	OST	2016-12-08	\N	"Crush U" is a song by EXO-CBX. It was released on December 8, 2016. "Crush You" is an OST for the massively multiplayer online role-playing game Blade & Soul. It was premiered at the "Blade & Soul World Championships" in Busan on November 18.
261	29	Beat It Up	MINI ALBUM	2025-11-17	\N	Beat It Up is the sixth mini album by NCT DREAM. It was released on November 17, 2025.
262	29	Go Back To The Future	STUDIO	2025-07-14	\N	Go Back To The Future is the fifth full-length album by NCT DREAM. It was released on July 14, 2025 with "BTTF" and "Chiller" serving as the album's double title tracks.
263	29	DREAMSCAPE	STUDIO	2024-11-11	Korean	Dreamscape is the fourth studio album by South Korean boy band NCT Dream. Released on November 11, 2024. The album consists of 11 tracks, including the previously released track "Rains in Heaven" and lead single "When I'm with You".
264	29	RE:WORKS	SINGLE	2024-10-10	Korean	"RE:WORKS" is a collaboration digital single by KENZIE, aespa, NCT DREAM and RIIZE. It was released on October 10, 2024."Supernova (KENZIE RE:WORKS)" was pre-released on October 7, 2024.
265	29	Rains in Heaven	SINGLE	2024-08-23	\N	"Rains in Heaven" is an English-language digital single by NCT Dream. It is described as a 1980s-style pop song with a harmonious blend of rhythmic drums and bass and emotional synth sounds, along with the members' sweet-sounding vocals.
266	29	Moonlight	SINGLE	2024-06-05	Japanese	"Moonlight" is the second Japanese single by NCT DREAM. It was released on June 5, 2024 with the title track of the same name.
267	29	DREAM( )SCAPE	MINI ALBUM	2024-03-25	\N	"DREAM( )SCAPE" is the fifth mini album by NCT Dream. It contains six songs, with "Smoothie" serving as the title track.
268	29	Broken Melodies (JVKE Remix)	SINGLE	2023-11-17	\N	"Broken Melodies (JVKE Remix)" is a remix digital single by NCT Dream, in collaboration with JVKE.
269	30	Heavy Serenade	EP	2026-05-11	Korean	"Heavy Serenade" is the fifth EP by NMIXX. It was released on May 11, 2026 with "Heavy Serenade" serving as the album's title track. "Crescendo" was pre-released on April 28, 2026.
270	30	TIC TIC (Feat. Pabllo Vittar)	SINGLE	2026-02-26	English	"Tic Tic (Feat. Pabllo Vittar)" is an English digital single by NMIXX and Brazilian singer Pabllo Vittar. It was released on February 26, 2026.
271	30	The 4th Love Revolution OST Part.1	OST	2025-11-13	\N	"The 4th Love Revolution OST Part.1" with the song "Up and Down" is the 2nd OST of NMIXX. It was released on November 13, 2025.
272	30	Mexe (Remix)	SINGLE	2025-10-21	English	"Mexe (Remix)" is the first English remix single NMIXX and Pabllo Vittar. It was released on October 21, 2025.
273	30	Blue Valentine (MIXX Ver.)	SINGLE	2025-10-17	\N	"Blue Valentine (MIXX Ver.)" Is the first remix single by NMIXX. It was released on October 17, 2025.
274	30	Blue Valentine	STUDIO	2025-10-13	Korean	“Blue Valentine” is the 1st Full Album from NMIXX. It was released on October 13, 2025.
276	30	Ridin' (Prod. THE HUB)	OST	2025-06-10	\N	"Ridin'" is a song released by NMIXX Lily, Jiwoo, and Kyujin, as part of the original soundtrack for "World of Street Woman Fighter". It was released on June 10, 2025.
277	30	Fe3O4: Forward	MINI ALBUM	2025-03-17	Korean	"Fe3O4: Forward" is NMIXX's fourth EP, with "Know About Me" as the title track.  It was released on March 17th 2025.
278	31	ICONIC HEART	SINGLE	\N	Japanese	"ICONIC HEART" is the first Japanese single by Hearts2Hearts. It will be released on August 12, 2026.
279	31	Lemon Tang	MINI ALBUM	2026-06-22	Korean	Lemon Tang is the second mini album by Hearts2Hearts. It was released on June 22, 2026 with Lemon Tang serving as the album's title track.
280	31	iScreaM Vol.39 : RUDE! Remixes	SINGLE	2026-03-27	Korean	iScreaM Vol.39 : RUDE! Remixes is a remix single by Hearts2Hearts featuring Silly Silky and yunji. It was released on March 27, 2026 under SM Entertainment and ScreaM Records, with “RUDE! (Silly Silky Remix)” serving as the single’s title track.
281	31	Rude! (Japanese Ver.)	SINGLE	2026-03-18	Japanese	"Rude! (Japanese Ver.)" is the first Japanese digital single by Hearts2Hearts. It was released March 18th, 2026 (JST).
282	31	RUDE!	SINGLE	2026-02-20	\N	"RUDE!" is a single by Hearts2Hearts. It was released on February 20, 2026. This serves as a pre release for the mini album 'Lemon Tang'.“The song ‘Rude’ talks about feelings of anger and disappointment in love or relationships, when someone feels mistreated or disrespected. The melody is often strong and intense, expressing bluntness (rude) and pent-up emotions.”
283	31	ScreaM Rookies: The Chase (Remixes)	MINI ALBUM	2025-12-17	Korean	ScreaM Rookies : The Chase (Remixes) is the second remix EP by Hearts2Hearts. The remix EP is made from the winning tracks from the ScreaM REMIX COMPITION that was held in July 2025. It was released on December 17, 2025.
284	31	FOCUS (Remixes)	MINI ALBUM	2025-11-21	\N	On November 21, 2025, Hearts2Hearts released the remix EP for their song 'FOCUS'.
285	31	Focus	MINI ALBUM	2025-10-20	Korean	"Focus" is a single album by Hearts2Hearts. It was released on October 20, 2025.
286	31	Pretty Please	SINGLE	2025-09-24	Korean	"Pretty Please" is the second digital single by Hearts2Hearts. It was released on September 24, 2025, as a pre-release single for the group's first mini album, Focus.
287	31	Style	SINGLE	2025-06-18	Korean	"Style" is a single by Hearts2Hearts. It was released on June 18, 2025.
288	32	My Christmas Sweet Love	SINGLE	2024-12-21	\N	My Christmas Sweet Love is the 6th special digital single by Dreamcatcher, it was released on December, 21, 2024.
289	32	Virtuous	MINI ALBUM	2024-07-10	Korean	"Virtuous" is the 10th mini album of Dreamcatcher. It contains a total of five songs, including the title track "Justice".
290	32	Luck Inside 7 Doors (2024 Concert Ver.)	SINGLE	2024-03-08	\N	"Luck Inside 7 Doors (2024 Concert Ver.)" is a special digital single album by Dreamcatcher. It consists of the concert version of their songs "Lullaby" and "The curse of the Spider."
291	32	VillainS	MINI ALBUM	2023-11-22	\N	"VillainS" is the ninth mini album by Dreamcatcher. It contains five tracks, with "OOTD" serving as the title song. The physical album comes in 12 versions: Limited (C), Normal (U, R, S and E), and seven individual poca versions.
292	32	[BONVOYAGE (Farewell Ver.)]	SINGLE	2023-09-14	\N	"[BONVOYAGE (Farewell Ver.)]" is the 1st English special digital single of Dreamcatcher. It was released on September 15, 2023.
293	32	Apocalypse : From Us	MINI ALBUM	2023-05-24	\N	"Apocalypse : From Us" is the eighth mini album of Dreamcatcher. It contains five songs, with "Bon Voyage" serving as the title track.
294	32	[REASON]	SINGLE	2023-01-13	Korean	"[REASON]" is a single by Dreamcatcher. It was released on January 12, 2023.
295	32	Apocalypse : Follow us	MINI ALBUM	2022-10-11	\N	"Apocalypse : Follow us" is the 7th mini album of Dreamcatcher it contains 6 total tracks, with "Vision" serving as the title track.
296	32	Apocalypse : Save Us	STUDIO	2022-04-12	\N	"Apocalypse : Save Us" is the second studio album of Dreamcatcher. It contains a total of fourteen songs, with "Maison" serving as the title track.
297	32	Summer Holiday	MINI ALBUM	2021-07-30	\N	"Summer Holiday" is the second special mini album by Dreamcatcher. It was released on July 30, 2021 with "BEcause" serving as the album's title track.
298	33	UNIQUE - Japan Edition	MINI ALBUM	\N	Japanese	P1Harmony will release a localized Japanese edition of their 9th mini-album, UNIQUE, on July 29, 2026. The special release features eight total tracks, including the title track "UNIQUE" as well as two brand-new songs recorded exclusively for this version.
299	33	UNIQUE	MINI ALBUM	2026-03-12	Korean	UNIQUE is the 9th mini album by P1Harmony. It was released on March 12, 2026 with the title track of the same name.
300	33	EX	MINI ALBUM	2025-09-26	English	EX is P1Harmony's first fully English album. It was released on the 26th of September 2025 and has a total of five tracks, including a Spanish version of the title track as well.
301	33	DUH!	MINI ALBUM	2025-05-08	Korean	'DUH!' is the 8th Mini Album by P1Harmony. It was released on May 8th, 2025 (6PM KST), with 'DUH!' serving as the albums title track.
302	33	STAGE FIGHTER (STF) Original, Vol. 2	SINGLE	2024-10-08	Korean	"R.O.P (Reign of Peace)" is a song released by P1HARMONY in the album "STAGE FIGHTER (STF) Original, Vol. 2". It was released on October 8, 2024.
303	33	SAD SONG	MINI ALBUM	2024-09-20	Korean	"SAD SONG" is the seventh mini album by P1Harmony. It released on September 20, 2024.  It contains 7 songs, with "Sad Song" serving as the title track.
304	33	Killin' It (English Version)	SINGLE	2024-05-13	English	"Killin' It (English Version)" is the third English-language digital single of P1HARMONY.
305	33	Killin' It	STUDIO	2024-02-05	Korean	"Killin' It" is the first full-length album of P1HARMONY. It contains 10 songs, with "Killin' It" serving as the title track.
306	33	Fall In Love Again	STUDIO	2023-11-09	Korean	"Fall In Love Again" is a single by P1harmony produced by C. “Tricky” Stewart & Believve.
307	33	JUMP (English Version)	SINGLE	2023-06-09	English	"JUMP (English Version)" is the 2nd English digital single by P1Harmony. It was released on June 9th, 2023.
308	34	Do It (Let's Play)	OST	2024-01-11	\N	"Do It (Let's Play)" is one of the theme songs for the game "NCT ZONE"
309	34	Marine Turtle	SINGLE	2023-12-06	\N	"Marine Turtle" is a single released by NCT U. It is sung by members Kun, Xiaojun, Renjun, and Chenle.
310	34	N.Y.C.T - NCT LAB	SINGLE	2023-09-07	\N	"N.Y.C.T" is a song by Haechan and Taeil which was released as part of the STATION: NCT LAB Project.
311	34	Rain Day	SINGLE	2022-07-19	\N	"Rain Day" is a song by Kun, Taeil, and Yangyang (credited as NCT U) which was released as part of the STATION: NCT LAB Project.
312	34	coNEXTion (Age of Light)	SINGLE	2022-03-20	Korean	NCT U's Doyoung, Mark, and Haechan released the song "coNEXTion (Age of Light)" as part of SM Station's NCT Lab.
313	34	Universe (Let's Play Ball)	SINGLE	2021-12-10	Korean	"Universe (Let's Play Ball)" is a pre-release single by NCT U. The song was included in NCT's third studio album "Universe".
314	34	Maxis By Ryan Jhun Pt. 1	SINGLE	2021-08-12	\N	NCT U (Doyoung and Haechan) released the song "Maniac" as part of composer Ryan Jhun's music project called "MAXIS By Ryan Jhun".
315	34	STATION X 4 LOVEs for Winter Part.2	SINGLE	2019-12-13	\N	"STATION X 4 LOVEs for Winter Part.2" is the fourth digital single by NCT U. It was released on December 13, 2019 as the second release of STATION X and is sung by Taeil, Doyoung, Jaehyun, and Haechan.
316	35	LUMINOUS	SINGLE	2022-09-28	Japanese	"Luminous" is the second Japanese single by LOONA. It was released on September 28, 2022.
317	35	Flip That	MINI ALBUM	2022-06-20	Korean	"Flip That" is the first special mini album by LOONA. It is a summer special which contains six songs, with "Flip That" serving as the title track.
318	35	<Queendom2> JINAON (Epilogue)	SINGLE	2022-06-03	Korean	"<Queendom2> JINAON (Epilogue)" is the second digital single from the survival program "Queendom 2". It was released on June 3, 2022.It is sung by Hyolyn, Brave Girls' Yuna, WJSN's SeolA, VIVIZ's Eunha, LOONA's HeeJin, and Kep1er's Yeseo.
319	35	<Queendom2> FINAL	EP	2022-05-27	Korean	"<Queendom2> FINAL" is a digital EP album from the survival program "Queendom 2". It was released on May 27, 2022 and is a compilation of singles for the final comeback competition.
320	35	<Queendom2> FANtastic QUEENDOM Part.1-2	COMPILATION	2022-05-26	Korean	"<Queendom2> FANtastic QUEENDOM Part.1-2" is the seventh digital compilation album from the survival program Queendom 2. It was released on May 26, 2022 and is a compilation of last three songs performed in the second part of the third round.
321	35	<Queendom2> Position Unit Battle Part.1-2	COMPILATION	2022-05-13	Korean	"<Queendom2> Position Unit Battle Part.1-2" is the fifth digital compilation album from the survival program "Queendom 2". It was released on May 13, 2022 and is a compilation of the original songs performed in the dance unit battle of the third round.The first unit, KeVIZ, consists of Kep1er's Xiaoting, Dayeon, and Hikaru, and VIVIZ's SinB and Umji.The second unit, Ex-it, consists of Hyolyn and WJSN's Eunseo and Yeoreum.The third unit, Queen Is Me, consists of Brave Girls' Eunji and LOONA's Yves, HeeJin, Choerry, and Olivia Hye.
322	35	<Queendom2> Position Unit Battle Part.1-1	SINGLE	2022-05-06	Korean	"<Queendom2> Position Unit Battle Part.1-1" is the first digital single from the survival program "Queendom 2". It was released on May 6, 2022.The single is sung by the unit "Sun and Moon", consisting of LOONA's JinSoul, HaSeul, Kim Lip, and Chuu, and Kep1er's Chaehyun and Youngeun.
323	35	<Queendom2> Part.2-1	COMPILATION	2022-04-15	Korean	"<Queendom2> Part.2-1" is the third digital compilation album from the survival program "Queendom 2". It was released on April 15, 2022 and is a compilation of the first three songs performed in the second round.
324	35	<Queendom2> Part.1-2	COMPILATION	2022-04-08	Korean	"<Queendom2> Part.1-2" is the second digital compilation album from the survival program "Queendom 2". It was released on April 8, 2022 and is a compilation of the remaining songs performed in the introduction.
325	35	Yummy-Yummy	SINGLE	2021-11-04	Korean	"Yummy-Yummy" is the second collaboration digital single by LOONA and the children's show COCOMONG. It was released on November 4, 2021, and features members YeoJin, Kim Lip, Choerry, and Go Won.
326	36	4WARD	SINGLE	2026-06-04	Korean	4WARD is a special single album by MAMAMOO. It was released on June 4, 2026, with "4 Flowers" serving as the title track.
327	36	[Hwa Sa Show Vol.3] MMM Smile	SINGLE	2023-02-19	\N	MAMAMOO
328	36	Mic On	MINI ALBUM	2022-10-11	\N	"Mic On" is the 12th mini album by MAMAMOO. It will be released on October 11, 2022 with "Illella" serving as the album's title track.The physical album comes in three versions: Main, Nemo, and 1Takes.
329	36	WAW (Japan Edition)	STUDIO	2021-09-29	\N	WAW (Japan Edition) is a Japanese full album by Mamamoo. It consists of 9 songs, including the Japanese version of "mumumumuch" and "Where are we now".
330	36	I Say MAMAMOO : The Best	STUDIO	2021-09-15	\N	"I Say MAMAMOO : The Best" is the first best album by MAMAMOO. It was released on September 15, 2021 with "Mumumumuch" serving as the album's title track. It includes new versions of their past title tracks and B-sides, as well as two new songs.
331	36	WAW	MINI ALBUM	2021-06-02	Korean	"WAW" (which stands for Where Are We) is the 11th mini album by MAMAMOO. It will be released on June 2, 2021 with "Where Are We Now" serving as the album's title track.
332	36	TRAVEL -Japan Edition-	MINI ALBUM	2021-02-03	\N	Discover TRAVEL -Japan Edition-, the official mini album from K-pop artist MAMAMOO. The album was released on 2021-02-03 under RBW Entertainment. The release features 10 tracks, including the title track "MAMAMOO - WANNA BE MYSELF". Explore the full tracklist, music videos, and concept photos below.
333	36	TRAVEL	MINI ALBUM	2020-11-03	\N	"Travel" is the 10th mini-album released by Mamamoo. The mini-album has 6 songs, with "Aya" serving as the title track.
334	36	Dingga	SINGLE	2020-10-20	\N	"Dingga" is a song by South Korean girl group MAMAMOO. It was released on October 20, 2020, as the lead single from the group's tenth extended play (EP), Travel.
335	36	WANNA BE MYSELF	SINGLE	2020-09-10	\N	"Wanna Be Myself" is the third special single by MAMAMOO. It was released on September 10, 2020 as a surprise gift for their fans who have been waiting for music from the group for a long time.
336	37	Season of Memories (Special Album)	SINGLE	2025-01-13	\N	Season of Memories is the first special album by GFRIEND. It was released on January 13, 2025 with "Season of Memories" serving as the album's title track. "Season of Memories" was pre-released on January 6, 2025.
337	37	Season of Memories	SINGLE	2025-01-06	\N	"Season of Memories" is the first digital single by GFRIEND. It was released on January 6, 2025, as the pre-release for their first special album Season of Memories.
338	37	回:Walpurgis Night	STUDIO	2020-11-09	\N	回:Walpurgis Night is the third full-length album by GFRIEND. It was released on November 9, 2020 with the song "Mago" serving as the album's title track.On October 12, 2020, it was reported that GFRIEND would come back on November 9 with a new studio album titled 回:Walpurgis Night. It's the third and last release of the series "回".
339	37	回:Song of the Sirens ~Apple~	SINGLE	2020-10-21	\N	'回:Song of the Sirens ~Apple~' is the seventh Japanese digital single released by South Korean girl group GFRIEND. It was released on October 21, 2020 under King Records. It was announced along with '回:Labyrinth ~Crossroads~'.
340	37	回:Labyrinth ~Crossroads~	SINGLE	2020-10-14	\N	'回:Labyrinth ~Crossroads~' is the sixth Japanese digital single by South Korean girl group GFRIEND. It was released on October 14, 2020 under King Records. It was announced the same day as '回:Song of the Sirens ~Apple~'.
341	37	回:Song of the Sirens	MINI ALBUM	2020-07-13	\N	回:Song of the Sirens is the ninth mini album by GFRIEND. It was released on July 13, 2020 with the song "Apple" serving as the album's title track.
342	37	回:LABYRINTH	STUDIO	2020-02-03	Korean	回:Labyrinth is the eighth mini album by GFRIEND. It was released on February 3, 2020 with "Crossroads" serving as the title track.The physical album comes in three versions: Crossroads, Room, and Twisted.
343	37	Fallin' Light	STUDIO	2019-11-13	\N	'Fallin' Light' is the third studio album and first Japanese language studio album by Korean girl group GFriend. It was released on November 13, 2019 under King Records.It consists of 10 tracks (Including one bonus track on the CD album making 11 tracks in total), two being Japanese versions of the groups hit Korean songs 'Sunrise' and 'Time For The Moon Night'.
344	37	FEVER SEASON	MINI ALBUM	2019-07-01	\N	Fever Season is the seventh mini album by GFRIEND. It was released on July 1, 2019 with "Fever" serving as the album's title track.The physical album comes in three versions: 熱(열), 帶(대), and 夜(야).
345	37	Just One Bite 2	OST	2019-03-20	\N	GFRIEND released the song "Cheers (ZZAN)" as part of the original television soundtrack of the drama "Just One Bite 2"
346	38	Moon	SINGLE	2025-04-19	Korean	Moon is the sixth digital single by ASTRO. It was released on April 19, 2025 as a tribute for Moon Bin and features VIVIZ, Minhyuk, Kihyun, I.M, Hoshi, Wonwoo, Mingyu, DK, Seungkwan, Hello Gloom, Rocky, Yoojung, Doyeon, Cha Ni, Bang Chan, and Moon Sua.
347	38	Twilight	SINGLE	2025-02-23	Korean	"Twilight" is the second special digital single by ASTRO. It was released on February 23, 2025, to celebrate the group's ninth debut anniversary.
348	38	Circles	SINGLE	2024-02-23	Korean	"Circles" is the first special digital single by ASTRO. It was released on February 23, 2024, to celebrate the group's eighth debut anniversary.
349	38	U&Iverse	SINGLE	2022-07-21	Korean	"U&Iverse" is the fifth digital single by ASTRO. It was released on July 21, 2022 as the 23rd release of the UNIVERSE Music project.This song is the group's last release with Moon Bin & Rocky.
350	38	Drive to the Starry Road	STUDIO	2022-05-16	Korean	"Drive to the Starry Road" is the third full length album of ASTRO. It features eleven songs, with "Candy Sugar Pop" serving as the title track. Moreover, this album marks MJ's last participation due to his military enlistment.
351	38	Ichiban Suki na Hito ni Sayonara wo Iou	SINGLE	2021-11-03	Japanese	"Ichiban Suki na Hito ni Sayonara wo Iou"  is the second Japanese digital single as well the first Japanese single by ASTRO.
352	38	ALIVE	SINGLE	2021-09-02	Korean	"ALIVE" is a special collaboration single by ASTRO together with the Universe platform. It was released on September 2nd, 2021.
353	38	All Good (Japanese Ver.)	STUDIO	2021-08-25	Japanese	"All Good (Japanese Ver.)" is a Japanese single by Astro. The song was also released as part of the original soundtrack of Tokyo MX Drama Series.
354	38	Switch On	MINI ALBUM	2021-08-02	Korean	"Switch On" is the 8th mini-album by Astro. It contains 6 songs, with "After Midnight" serving as the title track.
355	38	All Yours	STUDIO	2021-04-05	Korean	"All Yours" is the second full-length album by ASTRO. The album was released on April 5th, 2021 via Fantagio Music. The album was preceded by the title track "ONE".
356	39	Still Life	SINGLE	2022-04-05	Korean	"Still Life" is the second digital single of Bigbang. This marks Bigbang's first music release after four years, much to the delight of fans around the world. This is also Bigbang's first music release as a four-member group.
357	39	Flower Road	SINGLE	2018-03-13	\N	"Flower Road" is the first digital single by BIGBANG. It was released on March 13, 2018.
358	39	MADE	STUDIO	2016-12-12	\N	"MADE" is the third full-length album by BIGBANG. Among the 11 songs in the album, 8 of them were pre-released as digital singles over the year.
359	39	Made Series	STUDIO	2016-02-03	\N	"Made Series" is a japanese album by BIGBANG. It was released on February 3, 2016.
360	39	E	SINGLE	2015-08-05	Korean	"E" is the seventh single album by BIGBANG. It was released on August 5, 2015 as the fourth and final part in the MADE series.
361	39	D	SINGLE	2015-07-01	Korean	"D" is the sixth single album by BIGBANG. It was released on July 1, 2015 and is the third part of their MADE series.
362	39	A	SINGLE	2015-06-01	Korean	"A" is the fifth single album by BIGBANG. It was released on June 1, 2015 and is the second part of their MADE series.
363	39	M	SINGLE	2015-05-01	Korean	"M" is the fourth single album by BIGBANG. It was released on May 1, 2015 and is the first part of their MADE series.
364	39	Still Alive	REPACKAGE	2012-06-03	\N	"Still Alive" is the repackage version of Bigbang's fifth mini-album "Alive."  The album contains 9 songs, with "Monster" serving as the title track.
365	39	ALIVE	MINI ALBUM	2012-02-29	Korean	ALIVE is the fifth mini album by BIGBANG. It was released on February 29, 2012 with "Fantastic Baby" serving as the album's title track.
366	40	HOME	STUDIO	2026-06-08	Korean	Home (stylized in all-caps) is the first full-length album by BOYNEXTDOOR. It was released on June 8, 2026, with the title track "VIRAL".The music video for the track "ddok ddok ddok" was released on May 10, 2026.
367	40	Knock Knock Knock	SINGLE	2026-05-11	Korean	KNOCK KNOCK KNOCK is a digital single by BOYNEXTDOOR. It is a pre-release for their upcoming album "Home". The MV was released at 12am KST on May 11, 2026. While the digital version was released on music platforms at 6pm kst.
368	40	Perfect Crown Pt.3	OST	2026-04-17	Korean	BOYNEXTDOOR released their OST "No Doubt" for the MBC drama Perfect Crown on April 17, 2026.
369	40	Earth, Wind & Fire (Buldak Hotter Than My EX Ver.)	SINGLE	2026-02-08	Korean	"Earth, Wind & Fire (Buldak Hotter Than My EX Ver.)" is a single by BOYNEXTDOOR. It was released on February 8, 2026.
370	40	BOYNEXTDOOR TOUR "KNOCK ON Vol.1" FINAL (LIVE)	LIVE	2026-02-04	Korean	"BOYNEXTDOOR TOUR "KNOWCK ON Vol.1" FINAL (LIVE)" is a live album by BOYNEXTDOOR. It was released on February 4, 2026.
371	40	SAY CHEESE!	SINGLE	2025-11-10	Japanese	SAY CHEESE! is a digital single by BOYNEXTDOOR. It was released on November 10, 2025 under KOZ Entertainment, with “SAY CHEESE!” serving as the single’s title track.
372	40	The Action	MINI ALBUM	2025-10-20	\N	"The Action" is the fifth mini album by BOYNEXTDOOR. It is set to be released on October 20, 2025.
373	40	BOYLIFE	SINGLE	2025-08-18	\N	"Boylife" is the second Japanese single by BOYNEXTDOOR. It was released on August 18, 2025 with "Count To Love" serving as the single's title track.
374	40	No Genre	MINI ALBUM	2025-05-13	\N	No Genre is the fourth EP by BOYNEXTDOOR. It was released on May 13, 2025 with "I Feel Good" serving as the album's title track.
375	40	Never Loved This Way Before	OST	2025-03-14	\N	Discover Never Loved This Way Before, the official ost from K-pop artist BOYNEXTDOOR. The album was released on 2025-03-14. The release features 2 tracks, including the title track "Never Loved This Way Before". Explore the full tracklist, music videos, and concept photos below.
376	41	4SHOBOIZ Vol. 2: 4SHOVILLE	EP	2026-05-18	Korean	4SHOBOIZ Vol. 2: 4SHOVILLE is a collaborative mixtape by Jay Park and LNGSHOT. It was released on May 18, 2026 with the title track, "YEAH!  YEAH!".The music video to the opening track "4SHO 4SHO" was released on May 11, 2026.This is the second mixtape by LNGSHOT following the release of their pre-debut release, 4SHOBOIZ MIXTAPE'.
377	41	Training Day	EP	2026-03-23	Korean	"Training Day" is the second EP by LNGSHOT. It was released on March 23, 2026.
378	41	4SHOBOIZ MIXTAPE	MINI ALBUM	2026-01-16	Korean	"4SHOBOIZ MIXTAPE" is the first mixtape by LNGSHOT. It was released on January 16, 2026. This mixtape was previously released exclusively on Youtube.
379	41	SHOT CALLERS	MINI ALBUM	2026-01-13	Korean	"Shot Callers" is the debut EP by LNGSHOT. It was released on January 13, 2026. "Saucin'" was pre-released on December 22, 2025.
380	41	Saucin'	SINGLE	2025-12-22	\N	Saucin' is the first pre-debut digital single album by LNGSHOT. It was released on December 22, 2025
381	42	PANORAMA	SINGLE	2023-08-23	\N	"PANORAMA" is a special digital single by iKON.
382	42	TAKE OFF	STUDIO	2023-05-04	Korean	Take Off is the third full-length album by iKON. It was released on May 4, 2023 with "U" serving as the album's title track. "Tantara" was pre-released on April 25, 2023.The album marks their first release under 143 Entertainment, following their departure from YG Entertainment in December 2022.
383	42	FLASHBACK	MINI ALBUM	2022-05-03	Korean	Flashback is the fourth mini album by iKON. It was released on May 3, 2022 with "But You" serving as the album's title track.
384	42	At Ease	SINGLE	2021-05-28	\N	"At Ease" is a digital single released by iKON while participating in the show "Kingdom". The single was released together with other participating groups through the album called "WHO IS KING?"
385	42	Why Why Why	SINGLE	2021-03-03	Korean	"Why Why Why" is a digital single by iKON. It was released on March 3, 2021.
386	42	i DECIDE	MINI ALBUM	2020-02-06	\N	"I Decide" is the third mini-album released by iKON. It has 5 songs, with "Dive" serving as the album's title track.
387	42	New Kids Repackage : The New Kids	REPACKAGE	2019-01-07	Korean	"New Kids Repackage : The New Kids" is the first repackage album of iKON. It was released on January 7, 2019. It contains a total of twenty-two songs, all of which were previously released as part of iKON's "New Kids" album series. The album also features the new song "I'm OK" which serves as its title track.
388	42	New Kids: The Final	MINI ALBUM	2018-10-01	\N	Discover New Kids: The Final, the official mini album from K-pop artist iKON. The album was released on 2018-10-01. The release features 4 tracks, including the title track "GOODBYE ROAD". Explore the full tracklist, music videos, and concept photos below.
389	42	New Kids: Continue	MINI ALBUM	2018-08-01	\N	Discover New Kids: Continue, the official mini album from K-pop artist iKON. The album was released on 2018-08-01. The release features 5 tracks, including the title track "KILLING ME". Explore the full tracklist, music videos, and concept photos below.
390	42	Rubber Band	SINGLE	2018-03-05	\N	Discover Rubber Band, the official single from K-pop artist iKON. The album was released on 2018-03-05 under YG Entertainment, YGEX. The release features 1 tracks, including the title track "Rubber Band". Explore the full tracklist, music videos, and concept photos below.
391	43	I,God	MINI ALBUM	2026-05-27	Korean	"I,God" is the second mini album by XLOV. It was released on May 26, 2026 with “Serve” serving as the title track
392	43	UXLXVE	MINI ALBUM	2025-11-05	Korean	Uxlxve is the first mini album by XLOV. It was released on November 5, 2025 with "Rizz" serving as the album's title track and "Biii:-P" serving as the album's sub-title track.
393	43	I ONE	SINGLE	2025-06-13	Korean	"I One" is the second single album by XLOV. It was released on June 13, 2025 with "1&Only" serving as the single's title track.
394	43	I'mma Be	SINGLE	2025-01-07	Korean	"I'mma Be" is the debut single album by XLOV. It was released on January 7, 2025 with "I'mma Be" serving as the single's title track.
395	44	Regression LOVE	SINGLE	\N	Japanese	"Regression LOVE" is the 2nd japanese single by ZEROBASEONE. It will be released on August 19, 2026.
396	44	Ascend-	MINI ALBUM	2026-05-18	Korean	"Ascend-" is the sixth mini album by ZEROBASEONE. It was released on 18  May, 2026.
397	44	RE-FLOW	SINGLE	2026-02-02	Korean	"RE-FLOW" is the first special album by ZEROBASEONE. It was released on February 2, 2026 with "LOVEPOCALYPSE" serving as the title track."Running To Future" and "ROSES" were pre-released on January 9 and January 23, 2026, respectively.This is the groups final release as a nine-member group before the departures of members Zhang Hao, Ricky, Kim Gyu Vin, and Han Yu Jin.
398	44	Roses	SINGLE	2026-01-23	Korean	"ROSES" is the fifth digital single by ZEROBASEONE. It was released on January 23, 2026 as the second pre-release for their first special album, "RE-FLOW".
399	44	Running to Future	SINGLE	2026-01-09	Korean	"Running to Future" is the fourth digital single by ZEROBASEONE. It was released on January 9, 2026 as the first pre-release for their first special album, Re-Flow.
400	44	ICONIK	EP	2025-10-29	Japanese	"ICONIK" is the first Japanese special EP by ZEROBASEONE. It was released on October 29, 2025 with "Iconik (Japanese Ver.)" serving as the album's title track.
401	44	Never Say Never	STUDIO	2025-09-01	Korean	Never Say Never is the first full-length album by ZEROBASEONE. It was released on September 1, 2025."Slam Dunk" was pre-released on July 23, 2025.
402	44	Head Over Heels OST	OST	2025-07-30	Korean	"Head Over Heels Pt.2 OST" is a ost by various artists, including ZEROBASEONE, YOUNG POSSE, Choo Young-woo, Colde, Miyeon, Cheeze, and Jo Hyung-ah. It was released on July 29, 2025.
403	44	Slam Dunk	SINGLE	2025-07-23	Korean	"Slam Dunk" is the third digital single by ZEROBASEONE. It was released on July 23, 2025 as the pre-release for their first full-length album, Never Say Never.
404	44	Head over Heels OST Part.1	OST	2025-06-24	Korean	"Head over Heels OST Part.1" is an OST by ZEROBASEONE. It was released on June 24, 2025, as the first original soundtrack for the tvN drama Head over Heels.
405	45	ZERO:ATTITUDE (feat. pH-1)	SINGLE	2021-02-15	Korean	"ZERO:ATTITUDE" is a promotional single by Soyou and IZ*ONE (sung by Wonyoung, Sakura, Yuri, Eunbi, and Minju). It was released on February 15, 2021 as part of the 2021 Pepsi X Starship K-Pop Campaign and features pH-1.
406	45	D-D-DANCE	SINGLE	2021-01-26	Korean	"D-D-DANCE" is the first digital single by IZ*ONE. Made in collaboration with the platform UNIVERSE, it was released on January 26, 2021 as the first release of the UNIVERSE Music project. Its accompanying music video was released on January 28, 2021.It is the group's final single and release (as a full group) before disbanding on April 29, 2021.
407	45	One-reeler / Act IV	MINI ALBUM	2020-12-07	Korean	One-reeler / Act IV is the fourth mini album by IZ*ONE. It was released on December 7, 2020 with the song "Panorama" serving as the album's title track. "Sequence" was also promoted on music shows.It is the group's final mini album before disbanding on April 29, 2021.
408	45	Twelve	STUDIO	2020-10-21	Japanese	Twelve is the first and only Japanese full-length album by IZ*ONE. It was released on October 21, 2020 with "Beware" serving as the title track."Beware" was pre-released on October 7, 2020.
409	45	Oneiric Diary	MINI ALBUM	2020-06-15	Korean	Oneiric Diary (幻想日記) is the third mini album by IZ*ONE. It was released on June 15, 2020 with "Secret Story of the Swan" serving as the title track. "Pretty" was also promoted on music shows.The music video for "Secret Story of the Swan" was released on June 16.
410	45	BLOOM*IZ	STUDIO	2020-02-17	Korean	BLOOM*IZ is the first and only full-length album by IZ*ONE. It was released on February 17, 2020 with "FIESTA" serving as the album's title track.It was originally scheduled to be released on November 11, 2019 but was postponed due to the Produce 101 vote rigging controversy.
411	45	Vampire	SINGLE	2019-09-25	Japanese	"Vampire" is the third Japanese single by IZ*ONE. It was released on September 25, 2019.The music video for the title track was pre-released on September 12, 2019.
412	45	Buenos Aires	SINGLE	2019-06-21	Japanese	"Buenos Aires" is the second Japanese single by IZ*ONE. It was released digitally on June 21, 2019, and physically on June 26, 2019, with "Buenos Aires" serving as the title track.The music video for the title track was pre-released on June 12, 2019.
413	45	HEART*IZ	MINI ALBUM	2019-04-01	Korean	"HEART*IZ" is the second mini album by IZ*ONE. It was released on April 1, 2019 with "Violeta" serving as the album's title track.
414	45	Suki to Iwasetai	SINGLE	2019-02-06	Japanese	"Suki to Iwasetai" (好きと言わせたい; lit. I Want To Say I Like You) is the debut Japanese single by IZ*ONE. It was released on February 6, 2019 with "Suki to Iwasetai" serving as the title track.The music video for "Suki to Iwasetai" was released on January 25, 2019.
415	46	Mark on Me	MINI ALBUM	\N	Korean	"Mark on Me" is the second Korean mini album by &TEAM. It will be released on September 8, 2026.
416	46	We on Fire	MINI ALBUM	2026-04-13	Japanese	We on Fire is the third mini album by &TEAM. It was released digitally on April 13, 2026 with "We on Fire" serving as the album's title track. The physical albums were released on April 21, 2026."Sakura-iro Yell" was pre-released on March 14, 2026.
417	46	Back to Life	MINI ALBUM	2025-10-28	Korean	"Back to Life" is the first Korean mini album by &TEAM. It was released on October 28, 2025.
418	46	Go in Blind	SINGLE	2025-04-21	\N	Go in Blind is the 3rd single album by &TEAM. It was released on April 21st, 2025, with "Go in Blind" serving as the title track. "Go in Blind" was pre-released on April 14th, 2025.
419	46	Extraordinary Day	SINGLE	2025-02-02	\N	"Extraordinary Day" is the fifth digital single by &TEAM. It was released on February 2, 2025, for the tournament 2025 Beppu-Ōita Marathon.
420	46	Magic Hour / Wonderful World	OST	2025-01-09	\N	"Magic Hour / Wonderful World" is a soundtrack for the Japanese animated television series Honey Lemon Soda. It was released on January 9, 2025.
421	46	Yukiakari	STUDIO	2024-12-18	\N	"Yukiakari" is the second full-length album by &TEAM. It was released on December 18, 2024 with "Yukiakari" serving as the album's title track. "Deer Hunter" was also promoted on music shows.The pre-release single, "Jyuugoya" was released on October 23, 2024. "Illumination" and "Yukiakari" were pre-released on December 6 and December 16, 2024, respectively.
422	46	Jyuugoya	SINGLE	2024-10-23	\N	"Jyuugoya" is the fourth digital single by &TEAM. It was released on October 23, 2024 as the pre-release for their second full-length album Yukiakari.
423	46	Feel the Pulse	OST	2024-10-18	\N	"Feel the Pulse" is the OST for Golden Kamuy. It was released on October 18, 2024.
424	46	Beat the Odds	OST	2024-10-04	\N	"Beat the Odds" is the OST for Trillion Game. It was released on October 4, 2024.
425	47	CODE	MINI ALBUM	2026-03-03	Korean	"CODE" is the fourth mini album by EVERGLOW. It will be released on March 3, 2026.
426	47	Zombie	SINGLE	2024-06-10	Korean	"Zombie" is the fifth single album by EVERGLOW. It was released on June 10, 2024 with "Zombie" serving as the single's title track.
427	47	All My Girls	SINGLE	2023-08-18	\N	"ALL MY GIRLS" is the fourth single album by EVERGLOW. It contains three songs, with "Slay" serving as the title track. It was released on August 18, 2023.
428	47	Ghost Light (Nightcore)	SINGLE	2022-11-25	English	"Ghost Light (Nightcore)" is an English collaboration remix single by EVERGLOW and the German producer TheFatRat. It was released on November 25, 2022.
429	47	Ghost Light (with TheFatRat)	SINGLE	2022-11-18	English	"Ghost Light" is a collaboration digital single by EVERGLOW and the German producer TheFatRat. It was released on November 18, 2022. This single marks the first as a five-member group; Yiren was not present for its recording due to her remaining on hiatus.
430	47	Pirate (R3HAB Remix)	SINGLE	2022-04-15	\N	"Pirate (R3HAB Remix)" is the remix version of Everglow's song "Pirate" from their third mini album "Return of The Girl."
431	47	Return of the Girl	MINI ALBUM	2021-12-01	Korean	"Return of the Girl" is the third mini-album of Everglow. It contains five songs, with "Pirate" serving as the title track.
432	47	Promise	SINGLE	2021-08-25	\N	Everglow released the song "Promise" as part of the UNICEF PROMISE CAMPAIGN.
433	47	Last Melody	SINGLE	2021-05-25	Korean	"Last Melody" is the third single album by EVERGLOW. It will be released on May 25, 2021 with "First" serving as the single's title track. The album comes in two versions: Last Melody and First Memoir.
434	47	The Spies Who Loved Me OST	OST	2020-11-13	\N	Everglow released the song "Let Me Dance", a remake of the song by Lexy, as part of the original television soundtrack for the drama "The Spies Who Loved Me."
435	48	<Baby Flower City Remixes>	EP	2026-06-08	Korean	"Baby Flower City Remixes" is a remix album by tripleS. It was released on June 8, 2026.
436	48	Baby Flower Japanese Version	SINGLE	2026-06-03	Japanese	"Baby Flower -Japanese Ver.-" is the fourth Japanese digital single by tripleS. It was released on June 3, 2026.
437	48	<LOVE&POP> pt.1	MINI ALBUM	2026-06-01	Korean	<LOVE&POP> Pt.1 is the first installment of ASSEMBLE26 <LOVE&POP>, the third full-group album by tripleS. It was released on June 1, 2026, with 'Baby Flower' serving as the title track. It will come out as the “LOVE” part of a three-part project, followed by Part 2 “&” and Part 3 “POP.”The album features all 24 members and marks the group’s full-unit (“ASSEMBLE”) comeback for 2026. As the “LOVE” side of the project, Part 1 emphasizes themes of growth, connection, and emotional development, aligning with tripleS’s overarching narrative about “small ‘s’” individuals discovering their potential and becoming “S.”Conceptually, <LOVE&POP> Pt.1 focuses on the group’s “lovable” image and serves as the opening chapter of a larger storyline that expands tripleS’s universe. The project was announced as part of a dual-concept comeback plan for 2026, with the contrasting “POP” side highlighting a different musical and stylistic direction in later releasesPart 2 (“&”) is a Japanese release scheduled to come out in October 20, 2026. It serves as the transitional chapter between the contrasting “LOVE” and “POP” concepts.Part 3 (“POP”), scheduled for release in January 2027, will conclude the ASSEMBLE26 <LOVE&POP> project.
438	48	Tokimetique	SINGLE	2026-02-05	Japanese	"Tokimetique" (トキメティック) is the first remix single by ∞!. It was released on February 5, 2026.
439	48	4study4work4inst Vol.3	COMPILATION	2026-02-02	\N	4study4work4inst Vol.3 is the third instrumental album by tripleS. It was released on February 2, 2026 with "Are You Alive (Inst.)" serving as the album's title track.
440	48	msnz <Beyond Beauty>	MINI ALBUM	2025-11-24	Korean	msnz <Beyond Beauty> (also known simply as Beyond Beauty) is the debut mini album by msnz (Moon, Sun, Neptune, Zenith). It was released on November 24, 2025 with "Christmas Alone" serving as the album's title track.
441	48	tripleS ∞! <SecretHimitsuBimil>	EP	2025-10-01	Japanese	"SecretHimitsuBimil" is the first Japanese EP by ∞! (Hatchi!). It was released on October 1, 2025 with "Password" serving as the album's title track. "Password" was pre-released on September 17, 2025.
442	48	tripleS ∞! <Password>	SINGLE	2025-09-17	Japanese	"<Password>" is the first Japanese digital single by ∞!. It was released on September 17, 2025 as the pre-release for their first Japanese EP, <SecretHimitsuBimil>.
443	48	Pink Power	SINGLE	2025-07-17	Korean	"Pink Power" is a collaborative digital single by Zanmang Loopy and tripleS's SeoYeon, HyeRin, YuBin and ShiOn. It was released on July 17, 2025.
444	48	<ASSEMBLE25>	STUDIO	2025-05-12	Korean	<ASSEMBLE25> is the second full-length album by tripleS. It was released on May 12, 2025 with "Are You Alive" serving as the album's title track.
445	49	Super Junior25	STUDIO	2025-07-08	\N	Super Junior25 is the 12th full-length album by SUPER JUNIOR. It was released on July 12, 2025 with "Express Mode" serving as the album's title track.
446	49	Show Time	SINGLE	2024-06-11	\N	"Show Time" is a digital single by Super Junior, released in celebration of the group's 19th debut anniversary.
447	49	The Road : Celebration	STUDIO	2022-12-15	\N	"The Road : Celebration" is the second part of Super Junior's 11th full-length album. It contains five songs, with "Celebrate" serving as the title track.
448	49	The Road : Keep On Going	STUDIO	2022-07-12	\N	'The Road : Keep On Going' is the 11th studio album by Korean boy group SUPER JUNIOR under Label SJ, a subsidary of SM Entertainment. This marks them as the first artist to release 11 studio album's under the label.
449	49	The Road : Winter for Spring	SINGLE	2022-02-28	\N	"The Road : Winter for Spring" is a special single album of Super Junior. It contains four tracks, with "Callin'" serving as the title track.
450	49	The Renaissance - The 10th Album	STUDIO	2021-03-16	\N	"The Renaissance" is the 10th full-album by Super Junior. It contains 10 songs, with "House Party" serving as the title track.The song "The Melody" was first released in November 2020 to celebrate their 15th anniversary.
451	49	Star	STUDIO	2021-01-27	Japanese	Star is the first Japanese best album by SUPER JUNIOR. It was released on January 27, 2021 with "Star" serving as the album's title track.
452	50	The Core - 核	STUDIO	2026-01-23	English	"The Core - 核" is the first English full-length album by XG. It will be released on January 23, 2026 with "Hypnotize" serving as the album's title track. "Gala" and "4 Seasons" were pre-released on September 19 and December 24, 2025, respectively.
453	50	Gala	SINGLE	2025-09-19	English	"Gala" is the 10th digital single by XG. It will be released on September 19, 2025 as a pre-release for their first full-length album 'The Core - 核'.
454	50	XG 1st WORLD TOUR “The first HOWL” Live	STUDIO	2025-08-08	\N	"XG 1st WORLD TOUR 'The first HOWL' Live" is the first live album by the Japanese girl group XG. The 13-track album features live recordings taken from their concert at Japan’s Tokyo Dome in May 14, 2025. The album was released on August 8, 2025.
455	50	Million Places	SINGLE	2025-05-14	\N	"Million Places" is the fifth single album by XG. It will be released on May 14, 2025.
456	50	In The Rain	SINGLE	2025-04-11	English	The track was originally a b-side on their second mini-album AWE (released 8th November 2024) and was later released as a re-cut digital single on 11 April 2025.
457	50	Is This Love	SINGLE	2025-03-07	\N	"Is This Love" is the eighth digital single by XG. It will be released on March 7, 2025.
458	50	XDM Unidentified Waves	SINGLE	2025-01-31	\N	"XDM Unidentified Waves" is the 1st remix album of XG. It will be released on January 31, 2025.
459	50	Winter Without You -Orchestra Ver.-	SINGLE	2024-12-13	\N	"Winter Without You -Orchestra ver.-" is the seventh digital single by XG. It was released on December 13, 2024.
460	50	AWE	MINI ALBUM	2024-11-08	\N	"AWE" is the second mini album released by XG. It was released on November 8, 2024, with "Howling" serving as album’s title track.
461	50	IYKYK	SINGLE	2024-10-11	\N	Discover IYKYK, the official single from K-pop artist XG. The album was released on 2024-10-11. The release features 1 tracks, including the title track "IYKYK". Explore the full tracklist, music videos, and concept photos below.
\.


--
-- Data for Name: disbanded_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.disbanded_groups (id_group, disband_year, disband_reason) FROM stdin;
24	2019	\N
80	2023	\N
89	2024	\N
92	2023	\N
96	2023	\N
25	2019	\N
37	2021	\N
45	2021	\N
81	2023	\N
82	2023	\N
83	2023	\N
84	2023	\N
85	2023	\N
86	2024	\N
87	2023	\N
90	2024	\N
91	2024	\N
93	2023	\N
94	2024	\N
97	2023	\N
98	2022	\N
99	2025	\N
\.


--
-- Data for Name: fandom_colors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fandom_colors (id_fandom, color_identity) FROM stdin;
1	Purple
3	Black
3	Pink
4	Apricot
4	Neon-Magenta
7	Rose Quartz
7	Serenity
8	Pastel Coral
10	Green
10	White
12	Aurora Purple
12	Aurora Blue
13	Magenta
14	Pearl Neo Champagne
17	Red
17	Black
19	Lost
19	Guilty
19	Beautiful
20	Chic Violet
20	Neon Red
21	Pearl Aqua
23	Rose Pink
26	Pearl Neo Champagne
29	Sky Blue
30	PANTONE Black 6 C
30	PANTONE 7623 C
30	PANTONE P 10-6 C
34	Cloud Dancer
34	Scuba Blue
34	Ultra Violet
35	Vivid Plum
35	Space Violet
40	Tyrian Purple
41	Blue
46	Pearl Sapphire Blue
7	Pastel Coral
8	Rose Quartz
8	Serenity
11	Aurora Purple
11	Aurora Blue
47	Pearl Sapphire Blue
\.


--
-- Data for Name: fandoms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fandoms (id_fandom, id_group, name) FROM stdin;
1	1	ARMY
2	2	STAY
3	3	BLINK
4	4	ONCE
5	5	ENGENE
6	6	EXO-L
7	7	CARAT
8	8	ReVeluv
9	9	MOA
10	10	IGOT7/AhGaSe
11	11	ATINY
12	12	MY
13	13	MIDZY
14	14	NCTzens
15	15	FEARNOT
16	16	COER
17	17	MONSTIEZ
18	18	GLLIT
19	19	MONBEBE
20	20	Neverland
21	21	SHINee World
22	22	DIVE
23	23	S♡NE
24	24	Wannable
25	25	Bunnies
26	26	NCTzen
27	27	EYEKON
28	30	NSWER
29	31	S2U
30	32	InSomnia
31	33	P1ECE
32	35	Orbit
33	36	MOOMOO
34	37	BUDDY
35	38	AROHA
36	39	V.I.P
37	40	ONEDOOR
38	41	SHOTTIES
39	42	iKONIC
40	43	EVOL
41	44	ZEROSE
42	45	WIZ*ONE
43	46	LUNÉ
44	47	FOREVER
45	48	WAV
46	49	E.L.F.
47	50	ALPHAZ
\.


--
-- Data for Name: fans_fandoms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fans_fandoms (id_user, id_fandom) FROM stdin;
\.


--
-- Data for Name: fans_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fans_users (id_user, username, level, register_date) FROM stdin;
\.


--
-- Data for Name: fans_vote_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fans_vote_groups (id_user, id_group, id_voting, vote_timestamp) FROM stdin;
\.


--
-- Data for Name: group_idols; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_idols (id_group, id_idol, role) FROM stdin;
1	1	VISUAL
1	1	VOCALIST
1	2	RAPPER
1	3	DANCER
1	3	RAPPER
1	3	VOCALIST
1	4	LEADER
1	4	RAPPER
1	5	DANCER
1	5	VOCALIST
1	6	VISUAL
1	6	VOCALIST
1	7	DANCER
1	7	OTHERS
1	7	RAPPER
1	7	VOCALIST
2	8	LEADER
2	8	OTHERS
2	8	RAPPER
2	8	VOCALIST
2	9	DANCER
2	9	RAPPER
2	9	VOCALIST
2	10	OTHERS
2	10	RAPPER
2	10	VOCALIST
2	11	DANCER
2	11	RAPPER
2	11	VISUAL
2	11	VOCALIST
2	12	OTHERS
2	12	RAPPER
2	12	VOCALIST
2	13	DANCER
2	13	RAPPER
2	13	VOCALIST
2	14	VOCALIST
2	15	OTHERS
2	15	VOCALIST
3	16	VISUAL
3	16	VOCALIST
3	17	RAPPER
3	17	VOCALIST
3	18	DANCER
3	18	VOCALIST
3	19	DANCER
3	19	OTHERS
3	19	RAPPER
3	19	VOCALIST
4	20	DANCER
4	20	OTHERS
4	20	VOCALIST
4	21	VOCALIST
4	22	DANCER
4	22	RAPPER
4	22	VOCALIST
4	23	VOCALIST
4	24	LEADER
4	24	VOCALIST
4	25	DANCER
4	25	VOCALIST
4	26	RAPPER
4	26	VOCALIST
4	27	RAPPER
4	27	VOCALIST
4	28	DANCER
4	28	OTHERS
4	28	VISUAL
4	28	VOCALIST
5	29	DANCER
5	29	RAPPER
5	29	VOCALIST
5	30	DANCER
5	30	RAPPER
5	30	VOCALIST
5	31	DANCER
5	31	VISUAL
5	31	VOCALIST
5	32	DANCER
5	32	VOCALIST
5	33	DANCER
5	33	LEADER
5	33	VOCALIST
5	34	DANCER
5	34	OTHERS
5	34	RAPPER
5	34	VOCALIST
6	35	RAPPER
6	35	VOCALIST
6	36	LEADER
6	36	VISUAL
6	36	VOCALIST
6	37	DANCER
6	37	RAPPER
6	37	VOCALIST
6	38	VOCALIST
6	39	VOCALIST
6	40	RAPPER
6	40	VISUAL
6	40	VOCALIST
6	41	VOCALIST
6	42	DANCER
6	42	OTHERS
6	42	RAPPER
6	42	VISUAL
6	42	VOCALIST
6	43	DANCER
6	43	OTHERS
6	43	RAPPER
6	43	VISUAL
7	44	LEADER
7	44	RAPPER
7	44	VOCALIST
7	45	VISUAL
7	45	VOCALIST
7	46	VISUAL
7	46	VOCALIST
7	47	DANCER
7	47	VOCALIST
7	48	DANCER
7	48	LEADER
7	48	RAPPER
7	48	VOCALIST
7	49	RAPPER
7	49	VOCALIST
7	50	LEADER
7	50	OTHERS
7	50	VOCALIST
7	51	VOCALIST
7	52	OTHERS
7	52	RAPPER
7	52	VISUAL
7	52	VOCALIST
7	53	DANCER
7	53	RAPPER
7	53	VOCALIST
7	54	OTHERS
7	54	VOCALIST
7	55	OTHERS
7	55	RAPPER
7	55	VISUAL
7	55	VOCALIST
7	56	DANCER
7	56	OTHERS
7	56	RAPPER
7	56	VOCALIST
8	57	DANCER
8	57	LEADER
8	57	OTHERS
8	57	RAPPER
8	57	VISUAL
8	57	VOCALIST
8	58	DANCER
8	58	VOCALIST
8	59	VOCALIST
8	60	RAPPER
8	60	VOCALIST
8	61	OTHERS
8	61	RAPPER
8	61	VOCALIST
9	62	DANCER
9	62	RAPPER
9	62	VOCALIST
9	63	LEADER
9	63	RAPPER
9	63	VOCALIST
9	64	RAPPER
9	64	VISUAL
9	64	VOCALIST
9	65	DANCER
9	65	VOCALIST
9	66	DANCER
9	66	OTHERS
9	66	RAPPER
9	66	VOCALIST
10	67	RAPPER
10	67	VISUAL
10	67	VOCALIST
10	68	DANCER
10	68	LEADER
10	68	OTHERS
10	68	VOCALIST
10	69	DANCER
10	69	OTHERS
10	69	RAPPER
10	69	VOCALIST
10	70	VISUAL
10	70	VOCALIST
10	71	VOCALIST
10	72	DANCER
10	72	RAPPER
10	72	VOCALIST
10	73	DANCER
10	73	OTHERS
10	73	VOCALIST
11	74	OTHERS
11	74	RAPPER
11	74	VISUAL
11	74	VOCALIST
11	75	OTHERS
11	75	RAPPER
11	75	VOCALIST
11	76	DANCER
11	76	VOCALIST
11	77	OTHERS
11	77	RAPPER
11	77	VISUAL
11	77	VOCALIST
11	78	DANCER
11	78	VOCALIST
11	79	DANCER
11	79	RAPPER
11	79	VOCALIST
11	80	DANCER
11	80	VOCALIST
11	81	OTHERS
11	81	VOCALIST
12	82	DANCER
12	82	LEADER
12	82	OTHERS
12	82	RAPPER
12	82	VISUAL
12	82	VOCALIST
12	83	RAPPER
12	83	VOCALIST
12	84	DANCER
12	84	VISUAL
12	84	VOCALIST
12	85	OTHERS
12	85	VOCALIST
13	86	DANCER
13	86	LEADER
13	86	RAPPER
13	86	VOCALIST
13	87	RAPPER
13	87	VOCALIST
13	88	DANCER
13	88	OTHERS
13	88	RAPPER
13	88	VOCALIST
13	89	DANCER
13	89	RAPPER
13	89	VOCALIST
13	90	DANCER
13	90	OTHERS
13	90	RAPPER
13	90	VISUAL
13	90	VOCALIST
14	91	RAPPER
14	91	VOCALIST
14	92	DANCER
14	92	LEADER
14	92	OTHERS
14	92	RAPPER
14	92	VISUAL
14	92	VOCALIST
14	93	DANCER
14	93	RAPPER
14	93	VOCALIST
14	94	VOCALIST
14	95	DANCER
14	95	RAPPER
14	95	VISUAL
14	95	VOCALIST
14	96	DANCER
14	96	VISUAL
14	96	VOCALIST
14	97	DANCER
14	97	OTHERS
14	97	VOCALIST
15	98	DANCER
15	98	RAPPER
15	98	VOCALIST
15	99	DANCER
15	99	LEADER
15	99	VOCALIST
15	100	RAPPER
15	100	VOCALIST
15	101	DANCER
15	101	RAPPER
15	101	VOCALIST
15	102	DANCER
15	102	OTHERS
15	102	VOCALIST
16	103	DANCER
16	103	RAPPER
16	103	VOCALIST
16	104	RAPPER
16	104	VISUAL
16	104	VOCALIST
16	105	LEADER
16	105	RAPPER
16	105	VOCALIST
16	106	DANCER
16	106	VOCALIST
16	107	DANCER
16	107	OTHERS
16	107	VISUAL
16	107	VOCALIST
17	108	DANCER
17	108	RAPPER
17	109	VOCALIST
17	110	DANCER
17	110	RAPPER
17	110	VOCALIST
17	111	DANCER
17	111	OTHERS
17	111	RAPPER
17	111	VISUAL
17	111	VOCALIST
17	112	VOCALIST
17	113	VISUAL
17	113	VOCALIST
17	114	DANCER
17	114	OTHERS
17	114	RAPPER
17	114	VOCALIST
18	115	OTHERS
18	116	OTHERS
18	117	OTHERS
18	118	OTHERS
18	119	OTHERS
19	120	DANCER
19	120	LEADER
19	120	VOCALIST
19	121	VISUAL
19	121	VOCALIST
19	122	VOCALIST
19	123	DANCER
19	123	OTHERS
19	123	RAPPER
19	123	VISUAL
19	123	VOCALIST
19	124	RAPPER
19	124	VOCALIST
19	125	OTHERS
19	125	RAPPER
19	125	VOCALIST
20	126	VISUAL
20	126	VOCALIST
20	127	VOCALIST
20	128	LEADER
20	128	OTHERS
20	128	RAPPER
20	128	VOCALIST
20	129	DANCER
20	129	OTHERS
20	129	RAPPER
20	129	VOCALIST
20	130	OTHERS
20	130	VISUAL
20	130	VOCALIST
21	131	LEADER
21	131	VOCALIST
21	132	DANCER
21	132	RAPPER
21	132	VOCALIST
21	133	RAPPER
21	133	VISUAL
21	133	VOCALIST
21	134	DANCER
21	134	OTHERS
21	134	VOCALIST
22	135	DANCER
22	135	RAPPER
22	135	VOCALIST
22	136	DANCER
22	136	LEADER
22	136	VOCALIST
22	137	RAPPER
22	137	VOCALIST
22	138	DANCER
22	138	VISUAL
22	138	VOCALIST
22	139	VOCALIST
22	140	DANCER
22	140	OTHERS
22	140	VISUAL
22	140	VOCALIST
23	141	LEADER
23	141	VOCALIST
23	142	RAPPER
23	142	VOCALIST
23	143	RAPPER
23	143	VOCALIST
23	144	DANCER
23	144	RAPPER
23	144	VOCALIST
23	145	DANCER
23	145	RAPPER
23	145	VOCALIST
23	146	DANCER
23	146	RAPPER
23	146	VOCALIST
23	147	DANCER
23	147	OTHERS
23	147	RAPPER
23	147	VISUAL
23	147	VOCALIST
23	148	OTHERS
23	148	VOCALIST
24	149	LEADER
24	149	VOCALIST
24	150	VOCALIST
24	151	VISUAL
24	151	VOCALIST
24	152	DANCER
24	152	VOCALIST
24	153	VOCALIST
24	154	DANCER
24	154	OTHERS
24	154	RAPPER
24	154	VOCALIST
24	155	DANCER
24	155	RAPPER
24	155	VISUAL
24	155	VOCALIST
24	156	DANCER
24	156	RAPPER
24	157	DANCER
24	157	VISUAL
24	157	VOCALIST
24	158	DANCER
24	158	RAPPER
24	158	VOCALIST
24	159	OTHERS
24	159	RAPPER
25	160	OTHERS
25	161	OTHERS
25	162	OTHERS
25	163	OTHERS
26	91	DANCER
26	91	RAPPER
26	91	VOCALIST
26	92	DANCER
26	92	LEADER
26	92	OTHERS
26	92	RAPPER
26	92	VISUAL
26	92	VOCALIST
26	93	DANCER
26	93	RAPPER
26	93	VOCALIST
26	164	RAPPER
26	164	VOCALIST
26	94	VOCALIST
26	165	DANCER
26	165	RAPPER
26	165	VOCALIST
26	95	DANCER
26	95	RAPPER
26	95	VISUAL
26	95	VOCALIST
26	96	DANCER
26	96	VOCALIST
26	166	VOCALIST
26	167	DANCER
26	167	RAPPER
26	167	VISUAL
26	167	VOCALIST
26	168	DANCER
26	168	VOCALIST
26	169	DANCER
26	169	RAPPER
26	169	VISUAL
26	169	VOCALIST
26	97	DANCER
26	97	VOCALIST
26	170	DANCER
26	170	RAPPER
26	170	VISUAL
26	170	VOCALIST
26	171	DANCER
26	171	RAPPER
26	171	VOCALIST
26	172	VOCALIST
26	173	DANCER
26	173	RAPPER
26	173	VOCALIST
26	174	VOCALIST
26	175	RAPPER
26	176	DANCER
26	177	VOCALIST
26	178	VOCALIST
26	179	DANCER
26	179	OTHERS
26	179	RAPPER
26	179	VOCALIST
27	180	OTHERS
27	180	VISUAL
27	181	DANCER
27	181	LEADER
27	181	VOCALIST
27	182	DANCER
27	182	VOCALIST
27	183	DANCER
27	183	VOCALIST
27	184	DANCER
27	184	RAPPER
27	184	VOCALIST
27	185	DANCER
27	185	OTHERS
27	185	VOCALIST
28	35	DANCER
28	35	LEADER
28	35	RAPPER
28	35	VOCALIST
28	38	DANCER
28	38	RAPPER
28	38	VISUAL
28	38	VOCALIST
28	39	OTHERS
28	39	VOCALIST
29	168	DANCER
29	168	VOCALIST
29	169	DANCER
29	169	RAPPER
29	169	VISUAL
29	169	VOCALIST
29	97	VOCALIST
29	170	DANCER
29	170	OTHERS
29	170	RAPPER
29	170	VISUAL
29	172	VOCALIST
29	173	DANCER
29	173	OTHERS
29	173	RAPPER
29	173	VOCALIST
30	186	VOCALIST
30	187	LEADER
30	187	VOCALIST
30	188	VISUAL
30	188	VOCALIST
30	189	DANCER
30	189	VOCALIST
30	190	DANCER
30	190	RAPPER
30	191	DANCER
30	191	OTHERS
30	191	RAPPER
30	191	VOCALIST
31	192	VOCALIST
31	193	DANCER
31	193	LEADER
31	193	RAPPER
31	193	VISUAL
31	193	VOCALIST
31	194	DANCER
31	194	VOCALIST
31	195	VOCALIST
31	196	DANCER
31	196	RAPPER
31	196	VOCALIST
31	197	RAPPER
31	197	VISUAL
31	197	VOCALIST
31	198	DANCER
31	198	OTHERS
31	198	VISUAL
31	198	VOCALIST
31	199	OTHERS
31	199	VOCALIST
32	200	DANCER
32	200	LEADER
32	200	VISUAL
32	200	VOCALIST
32	201	DANCER
32	201	RAPPER
32	201	VOCALIST
32	202	VOCALIST
32	203	VOCALIST
32	204	VOCALIST
32	205	DANCER
32	205	RAPPER
32	205	VOCALIST
32	206	OTHERS
32	206	RAPPER
32	206	VOCALIST
33	207	VOCALIST
33	208	LEADER
33	208	VISUAL
33	208	VOCALIST
33	209	DANCER
33	209	RAPPER
33	209	VOCALIST
33	210	DANCER
33	210	RAPPER
33	210	VISUAL
33	210	VOCALIST
33	211	DANCER
33	211	RAPPER
33	211	VOCALIST
33	212	DANCER
33	212	OTHERS
33	212	RAPPER
34	91	DANCER
34	91	RAPPER
34	91	VOCALIST
34	92	DANCER
34	92	OTHERS
34	92	RAPPER
34	92	VISUAL
34	92	VOCALIST
34	93	DANCER
34	93	RAPPER
34	93	VOCALIST
34	164	VOCALIST
34	94	VOCALIST
34	165	DANCER
34	165	RAPPER
34	165	VOCALIST
34	95	DANCER
34	95	RAPPER
34	95	VISUAL
34	95	VOCALIST
34	96	DANCER
34	96	VOCALIST
34	166	RAPPER
34	166	VOCALIST
34	167	DANCER
34	167	RAPPER
34	167	VISUAL
34	167	VOCALIST
34	168	DANCER
34	168	VOCALIST
34	169	DANCER
34	169	RAPPER
34	169	VISUAL
34	169	VOCALIST
34	97	DANCER
34	97	VOCALIST
34	170	DANCER
34	170	RAPPER
34	170	VISUAL
34	170	VOCALIST
34	171	DANCER
34	171	RAPPER
34	171	VOCALIST
34	172	VOCALIST
34	173	DANCER
34	173	OTHERS
34	173	RAPPER
34	173	VOCALIST
35	213	OTHERS
35	214	LEADER
35	215	OTHERS
35	216	LEADER
35	217	LEADER
35	218	OTHERS
35	219	DANCER
35	219	RAPPER
35	219	VOCALIST
35	220	DANCER
35	220	RAPPER
35	220	VOCALIST
35	221	DANCER
35	221	RAPPER
35	221	VOCALIST
35	222	DANCER
35	222	RAPPER
35	222	VOCALIST
35	223	OTHERS
35	223	RAPPER
35	223	VOCALIST
36	224	LEADER
36	224	VOCALIST
36	225	OTHERS
36	225	RAPPER
36	226	OTHERS
36	226	VOCALIST
36	227	OTHERS
36	227	RAPPER
36	227	VOCALIST
37	228	LEADER
37	228	VISUAL
37	228	VOCALIST
37	229	DANCER
37	229	OTHERS
37	229	VOCALIST
37	230	VOCALIST
37	231	VOCALIST
37	232	DANCER
37	232	OTHERS
37	232	VOCALIST
37	233	OTHERS
37	233	VOCALIST
38	234	VOCALIST
38	235	DANCER
38	235	LEADER
38	235	RAPPER
38	236	OTHERS
38	236	VISUAL
38	236	VOCALIST
38	237	OTHERS
38	237	VOCALIST
39	238	DANCER
39	238	OTHERS
39	238	VOCALIST
39	239	LEADER
39	239	OTHERS
39	239	RAPPER
39	239	VOCALIST
39	240	OTHERS
39	240	VOCALIST
40	241	VOCALIST
40	242	DANCER
40	242	VOCALIST
40	243	LEADER
40	243	RAPPER
40	243	VOCALIST
40	244	RAPPER
40	244	VISUAL
40	244	VOCALIST
40	245	VISUAL
40	245	VOCALIST
40	246	OTHERS
40	246	RAPPER
40	246	VOCALIST
41	247	DANCER
41	247	LEADER
41	247	VOCALIST
41	248	RAPPER
41	248	VOCALIST
41	249	DANCER
41	249	OTHERS
41	249	RAPPER
41	249	VOCALIST
41	250	OTHERS
41	250	VOCALIST
42	251	DANCER
42	251	LEADER
42	251	OTHERS
42	251	VOCALIST
42	252	OTHERS
42	252	VISUAL
42	252	VOCALIST
42	253	OTHERS
42	253	RAPPER
42	253	VOCALIST
42	254	DANCER
42	254	RAPPER
42	254	VOCALIST
42	255	VOCALIST
42	256	OTHERS
42	256	VOCALIST
43	257	LEADER
43	257	OTHERS
43	257	VOCALIST
43	258	DANCER
43	258	VISUAL
43	258	VOCALIST
43	259	RAPPER
43	259	VOCALIST
43	260	DANCER
43	260	OTHERS
43	260	RAPPER
43	260	VOCALIST
44	261	RAPPER
44	261	VISUAL
44	261	VOCALIST
44	262	DANCER
44	262	LEADER
44	262	VISUAL
44	262	VOCALIST
44	263	DANCER
44	263	RAPPER
44	263	VOCALIST
44	264	VOCALIST
44	265	DANCER
44	265	OTHERS
44	265	RAPPER
44	265	VOCALIST
45	266	DANCER
45	266	LEADER
45	266	VOCALIST
45	98	RAPPER
45	98	VISUAL
45	98	VOCALIST
45	267	RAPPER
45	267	VISUAL
45	267	VOCALIST
45	268	DANCER
45	268	RAPPER
45	268	VOCALIST
45	269	DANCER
45	269	RAPPER
45	269	VOCALIST
45	99	DANCER
45	99	VOCALIST
45	270	RAPPER
45	270	VISUAL
45	270	VOCALIST
45	271	VOCALIST
45	272	DANCER
45	272	RAPPER
45	272	VOCALIST
45	273	VOCALIST
45	136	DANCER
45	136	VOCALIST
45	138	DANCER
45	138	OTHERS
45	138	RAPPER
45	138	VOCALIST
46	274	DANCER
46	274	LEADER
46	274	OTHERS
46	275	LEADER
46	276	RAPPER
46	276	VOCALIST
46	277	LEADER
46	278	VOCALIST
46	279	OTHERS
46	279	VISUAL
46	279	VOCALIST
46	280	VISUAL
46	280	VOCALIST
46	281	DANCER
46	281	VOCALIST
46	282	OTHERS
46	282	VOCALIST
47	283	DANCER
47	283	RAPPER
47	284	LEADER
47	284	VOCALIST
47	285	DANCER
47	285	VOCALIST
47	286	DANCER
47	286	OTHERS
47	286	RAPPER
47	286	VOCALIST
48	287	LEADER
48	287	OTHERS
48	287	VISUAL
48	287	VOCALIST
48	288	LEADER
48	288	VOCALIST
48	289	LEADER
48	289	VISUAL
48	290	DANCER
48	290	RAPPER
48	290	VOCALIST
48	291	DANCER
48	291	OTHERS
48	291	RAPPER
48	291	VOCALIST
48	292	VOCALIST
48	293	RAPPER
48	294	LEADER
48	294	VOCALIST
48	295	DANCER
48	296	DANCER
48	296	RAPPER
48	297	VOCALIST
48	298	DANCER
48	298	VISUAL
48	298	VOCALIST
48	299	VOCALIST
48	300	DANCER
48	300	RAPPER
48	300	VISUAL
48	300	VOCALIST
48	301	VOCALIST
48	302	DANCER
48	303	LEADER
48	304	DANCER
48	304	LEADER
48	305	VOCALIST
48	306	DANCER
48	306	LEADER
48	306	VOCALIST
48	307	VOCALIST
48	308	DANCER
48	308	VOCALIST
48	309	VISUAL
48	310	OTHERS
48	310	VOCALIST
49	311	LEADER
49	311	OTHERS
49	311	RAPPER
49	311	VOCALIST
49	312	OTHERS
49	312	RAPPER
49	312	VISUAL
49	312	VOCALIST
49	313	VOCALIST
49	314	DANCER
49	314	RAPPER
49	314	VOCALIST
49	315	DANCER
49	315	VOCALIST
49	316	DANCER
49	316	RAPPER
49	316	VOCALIST
49	317	OTHERS
49	317	VISUAL
49	317	VOCALIST
49	318	DANCER
49	318	RAPPER
49	318	VISUAL
49	318	VOCALIST
49	319	VOCALIST
49	320	VOCALIST
50	321	LEADER
50	321	VOCALIST
50	322	DANCER
50	322	VOCALIST
50	323	DANCER
50	323	LEADER
50	323	RAPPER
50	323	VOCALIST
50	324	RAPPER
50	324	VOCALIST
50	325	VOCALIST
50	326	RAPPER
50	326	VOCALIST
50	327	OTHERS
50	327	RAPPER
35	219	OTHERS
7	44	DANCER
7	44	OTHERS
7	44	VISUAL
7	45	DANCER
7	47	RAPPER
7	48	OTHERS
8	49	LEADER
8	49	RAPPER
8	49	VOCALIST
8	50	VISUAL
8	50	VOCALIST
8	51	VISUAL
8	51	VOCALIST
8	52	DANCER
8	52	VOCALIST
8	53	DANCER
8	53	LEADER
8	53	RAPPER
8	53	VOCALIST
8	54	RAPPER
8	54	VOCALIST
8	55	LEADER
8	55	OTHERS
8	55	VOCALIST
8	56	VOCALIST
8	58	RAPPER
8	59	OTHERS
8	60	OTHERS
8	60	VISUAL
8	61	DANCER
10	66	RAPPER
10	66	VISUAL
10	66	VOCALIST
10	67	DANCER
10	67	LEADER
10	67	OTHERS
10	68	RAPPER
10	69	VISUAL
10	71	DANCER
10	71	RAPPER
10	72	OTHERS
11	73	DANCER
11	73	LEADER
11	73	OTHERS
11	73	RAPPER
11	73	VISUAL
11	73	VOCALIST
11	75	DANCER
11	75	VISUAL
11	76	OTHERS
12	77	OTHERS
12	77	RAPPER
12	77	VISUAL
12	77	VOCALIST
12	78	OTHERS
12	78	RAPPER
12	78	VOCALIST
12	79	DANCER
12	79	VOCALIST
12	80	OTHERS
12	80	RAPPER
12	80	VISUAL
12	80	VOCALIST
12	81	DANCER
12	81	VOCALIST
12	83	DANCER
12	84	OTHERS
13	85	DANCER
13	85	LEADER
13	85	RAPPER
13	85	VOCALIST
13	87	DANCER
13	87	OTHERS
13	89	OTHERS
13	89	VISUAL
14	90	RAPPER
14	90	VOCALIST
14	91	DANCER
14	93	VISUAL
14	94	DANCER
14	94	VISUAL
14	95	OTHERS
15	96	DANCER
15	96	RAPPER
15	96	VOCALIST
15	97	DANCER
15	97	LEADER
15	97	VOCALIST
15	99	RAPPER
15	100	DANCER
15	100	OTHERS
16	101	DANCER
16	101	RAPPER
16	101	VOCALIST
16	102	RAPPER
16	102	VISUAL
16	102	VOCALIST
16	103	LEADER
16	104	DANCER
16	105	DANCER
16	105	OTHERS
16	105	VISUAL
17	106	DANCER
17	106	RAPPER
17	107	VISUAL
17	107	VOCALIST
17	108	VOCALIST
17	109	DANCER
17	109	OTHERS
17	109	RAPPER
17	109	VISUAL
17	112	DANCER
17	112	OTHERS
17	112	RAPPER
18	113	OTHERS
18	114	OTHERS
19	118	DANCER
19	118	LEADER
19	118	VOCALIST
19	119	VISUAL
19	119	VOCALIST
19	121	DANCER
19	121	OTHERS
19	121	RAPPER
19	122	OTHERS
19	122	RAPPER
20	123	VISUAL
20	123	VOCALIST
20	124	VOCALIST
20	125	LEADER
20	125	OTHERS
20	125	RAPPER
20	125	VOCALIST
20	126	DANCER
20	126	OTHERS
20	126	RAPPER
20	127	OTHERS
20	127	VISUAL
21	128	LEADER
21	128	VOCALIST
21	129	DANCER
21	129	RAPPER
21	129	VOCALIST
21	130	RAPPER
21	130	VISUAL
21	130	VOCALIST
21	131	DANCER
21	131	OTHERS
22	132	DANCER
22	132	RAPPER
22	132	VOCALIST
22	133	RAPPER
22	133	VOCALIST
22	134	DANCER
22	134	VISUAL
22	134	VOCALIST
22	136	OTHERS
22	136	VISUAL
23	137	LEADER
23	137	VOCALIST
23	138	RAPPER
23	138	VOCALIST
23	139	RAPPER
23	139	VOCALIST
23	140	DANCER
23	140	RAPPER
23	140	VOCALIST
23	141	DANCER
23	141	RAPPER
23	142	DANCER
23	143	DANCER
23	143	OTHERS
23	143	VISUAL
23	144	OTHERS
24	145	OTHERS
24	146	OTHERS
24	147	OTHERS
24	148	OTHERS
25	149	VOCALIST
25	150	VISUAL
25	150	VOCALIST
25	151	DANCER
25	151	VOCALIST
25	152	VOCALIST
25	153	DANCER
25	153	OTHERS
25	153	RAPPER
25	153	VOCALIST
25	154	DANCER
25	154	RAPPER
25	154	VISUAL
25	154	VOCALIST
25	155	DANCER
25	155	RAPPER
25	156	DANCER
25	156	VISUAL
25	156	VOCALIST
25	157	DANCER
25	157	RAPPER
25	157	VOCALIST
25	158	OTHERS
25	158	RAPPER
26	90	DANCER
26	90	RAPPER
26	90	VOCALIST
26	159	RAPPER
26	159	VOCALIST
26	160	DANCER
26	160	RAPPER
26	160	VOCALIST
26	93	VISUAL
26	94	DANCER
26	161	VOCALIST
26	162	DANCER
26	162	RAPPER
26	162	VISUAL
26	162	VOCALIST
26	163	DANCER
26	163	VOCALIST
26	164	DANCER
26	164	VISUAL
26	165	VISUAL
26	166	DANCER
26	166	RAPPER
26	168	RAPPER
26	173	OTHERS
27	174	OTHERS
27	174	VISUAL
27	175	DANCER
27	175	LEADER
27	175	VOCALIST
27	176	DANCER
27	176	VOCALIST
27	177	DANCER
27	177	VOCALIST
27	178	DANCER
27	178	RAPPER
27	178	VOCALIST
27	179	DANCER
27	179	OTHERS
27	179	VOCALIST
29	163	DANCER
29	163	VOCALIST
29	164	DANCER
29	164	RAPPER
29	164	VISUAL
29	164	VOCALIST
29	95	VOCALIST
29	165	DANCER
29	165	OTHERS
29	165	RAPPER
29	165	VISUAL
29	167	VOCALIST
29	168	OTHERS
29	168	RAPPER
30	180	LEADER
30	180	VOCALIST
30	181	VISUAL
30	181	VOCALIST
30	182	DANCER
30	182	VOCALIST
30	183	DANCER
30	183	RAPPER
30	184	DANCER
30	184	OTHERS
30	184	RAPPER
30	184	VOCALIST
31	185	VOCALIST
31	186	DANCER
31	186	LEADER
31	186	RAPPER
31	186	VISUAL
31	186	VOCALIST
31	187	DANCER
31	187	VOCALIST
31	188	VOCALIST
31	189	DANCER
31	189	RAPPER
31	189	VOCALIST
31	190	RAPPER
31	190	VISUAL
31	190	VOCALIST
31	191	DANCER
31	191	OTHERS
31	191	VISUAL
31	191	VOCALIST
31	192	OTHERS
32	193	DANCER
32	193	LEADER
32	193	VISUAL
32	193	VOCALIST
32	194	DANCER
32	194	RAPPER
32	194	VOCALIST
32	195	VOCALIST
32	196	VOCALIST
32	197	VOCALIST
32	198	DANCER
32	198	RAPPER
32	198	VOCALIST
32	199	OTHERS
32	199	RAPPER
32	199	VOCALIST
33	200	VOCALIST
33	201	LEADER
33	201	VISUAL
33	201	VOCALIST
33	202	DANCER
33	202	RAPPER
33	202	VOCALIST
33	203	DANCER
33	203	RAPPER
33	203	VISUAL
33	203	VOCALIST
33	204	DANCER
33	204	RAPPER
33	204	VOCALIST
33	205	DANCER
33	205	OTHERS
33	205	RAPPER
34	90	DANCER
34	90	RAPPER
34	90	VOCALIST
34	159	VOCALIST
34	160	DANCER
34	160	RAPPER
34	160	VOCALIST
34	93	VISUAL
34	94	DANCER
34	161	RAPPER
34	161	VOCALIST
34	162	DANCER
34	162	RAPPER
34	162	VISUAL
34	162	VOCALIST
34	163	DANCER
34	163	VOCALIST
34	164	DANCER
34	164	RAPPER
34	164	VISUAL
34	165	VISUAL
34	166	DANCER
34	168	OTHERS
34	168	RAPPER
35	206	OTHERS
35	207	LEADER
35	208	OTHERS
35	209	LEADER
35	210	LEADER
35	211	OTHERS
35	212	OTHERS
35	213	DANCER
35	213	RAPPER
35	213	VOCALIST
35	214	DANCER
35	214	RAPPER
35	214	VOCALIST
35	215	DANCER
35	215	RAPPER
35	215	VOCALIST
35	216	OTHERS
35	216	RAPPER
35	216	VOCALIST
36	217	LEADER
36	217	VOCALIST
36	218	OTHERS
36	218	RAPPER
36	219	OTHERS
36	219	VOCALIST
36	220	OTHERS
36	220	RAPPER
36	220	VOCALIST
37	221	LEADER
37	221	VISUAL
37	221	VOCALIST
37	222	DANCER
37	222	OTHERS
37	222	VOCALIST
37	223	VOCALIST
37	224	VOCALIST
37	225	DANCER
37	225	OTHERS
37	225	VOCALIST
37	226	OTHERS
37	226	VOCALIST
38	227	VOCALIST
38	228	DANCER
38	228	LEADER
38	228	RAPPER
38	229	OTHERS
38	229	VISUAL
38	229	VOCALIST
38	230	OTHERS
38	230	VOCALIST
39	231	DANCER
39	231	OTHERS
39	231	VOCALIST
39	232	LEADER
39	232	OTHERS
39	232	RAPPER
39	232	VOCALIST
39	233	OTHERS
39	233	VOCALIST
40	234	VOCALIST
40	235	DANCER
40	235	VOCALIST
40	236	LEADER
40	236	RAPPER
40	236	VOCALIST
40	237	RAPPER
40	237	VISUAL
40	237	VOCALIST
40	238	VISUAL
40	238	VOCALIST
40	239	OTHERS
40	239	RAPPER
40	239	VOCALIST
41	240	DANCER
41	240	LEADER
41	240	VOCALIST
41	241	RAPPER
41	241	VOCALIST
41	242	DANCER
41	242	OTHERS
41	242	RAPPER
41	242	VOCALIST
41	243	OTHERS
41	243	VOCALIST
42	244	DANCER
42	244	LEADER
42	244	OTHERS
42	244	VOCALIST
42	245	OTHERS
42	245	VISUAL
42	245	VOCALIST
42	246	OTHERS
42	246	RAPPER
42	246	VOCALIST
42	247	DANCER
42	247	RAPPER
42	247	VOCALIST
42	248	VOCALIST
42	249	OTHERS
42	249	VOCALIST
43	250	LEADER
43	250	OTHERS
43	250	VOCALIST
43	251	DANCER
43	251	VISUAL
43	251	VOCALIST
43	252	RAPPER
43	252	VOCALIST
43	253	DANCER
43	253	OTHERS
43	253	RAPPER
43	253	VOCALIST
44	254	RAPPER
44	254	VISUAL
44	254	VOCALIST
44	255	DANCER
44	255	LEADER
44	255	VISUAL
44	255	VOCALIST
44	256	DANCER
44	256	RAPPER
44	256	VOCALIST
44	257	VOCALIST
44	258	DANCER
44	258	OTHERS
44	258	RAPPER
44	258	VOCALIST
45	259	DANCER
45	259	LEADER
45	259	VOCALIST
45	96	RAPPER
45	96	VISUAL
45	96	VOCALIST
45	260	RAPPER
45	260	VISUAL
45	260	VOCALIST
45	261	DANCER
45	261	RAPPER
45	261	VOCALIST
45	262	DANCER
45	262	RAPPER
45	262	VOCALIST
45	97	DANCER
45	97	VOCALIST
45	263	RAPPER
45	263	VISUAL
45	263	VOCALIST
45	264	VOCALIST
45	265	DANCER
45	265	RAPPER
45	265	VOCALIST
45	134	DANCER
45	134	OTHERS
45	134	RAPPER
45	134	VOCALIST
46	267	DANCER
46	267	LEADER
46	267	OTHERS
46	268	LEADER
46	269	RAPPER
46	269	VOCALIST
46	270	LEADER
46	271	VOCALIST
46	272	OTHERS
46	272	VISUAL
46	272	VOCALIST
46	273	VISUAL
46	273	VOCALIST
46	274	VOCALIST
46	275	OTHERS
46	275	VOCALIST
47	276	DANCER
47	276	RAPPER
47	277	LEADER
47	277	VOCALIST
47	278	DANCER
47	278	VOCALIST
47	279	DANCER
47	279	OTHERS
47	279	RAPPER
47	279	VOCALIST
48	280	LEADER
48	280	OTHERS
48	280	VISUAL
48	280	VOCALIST
48	281	LEADER
48	281	VOCALIST
48	282	LEADER
48	282	VISUAL
48	283	DANCER
48	283	RAPPER
48	283	VOCALIST
48	284	DANCER
48	284	OTHERS
48	284	RAPPER
48	284	VOCALIST
48	285	VOCALIST
48	286	RAPPER
48	288	DANCER
48	289	DANCER
48	289	RAPPER
48	291	VISUAL
48	293	DANCER
48	293	VISUAL
48	293	VOCALIST
48	296	LEADER
48	297	DANCER
48	297	LEADER
48	299	DANCER
48	299	LEADER
48	301	DANCER
48	302	VISUAL
48	303	OTHERS
48	303	VOCALIST
49	304	DANCER
49	304	VOCALIST
49	305	RAPPER
49	305	VOCALIST
49	306	VISUAL
49	306	VOCALIST
49	307	RAPPER
49	307	VOCALIST
49	308	OTHERS
49	308	VISUAL
49	308	VOCALIST
50	309	LEADER
50	309	OTHERS
50	309	RAPPER
50	309	VOCALIST
50	310	OTHERS
50	310	RAPPER
50	310	VISUAL
50	310	VOCALIST
50	311	VOCALIST
50	312	DANCER
50	312	RAPPER
50	312	VOCALIST
50	313	DANCER
50	313	VOCALIST
50	314	DANCER
50	314	RAPPER
50	314	VOCALIST
50	315	OTHERS
50	315	VISUAL
50	315	VOCALIST
50	316	DANCER
50	316	RAPPER
50	316	VISUAL
50	316	VOCALIST
50	317	VOCALIST
50	318	VOCALIST
\.


--
-- Data for Name: group_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_metrics (id_group, scraped_at, rank, total_bias_votes, dance_score, vocal_score, stage_score, artistry_score, visual_score) FROM stdin;
1	2026-07-20 22:27:51	1	6685	77.00	76.00	77.00	77.00	76.00
2	2026-07-20 22:27:51	2	5073	95.00	95.00	95.00	95.00	95.00
3	2026-07-20 22:27:51	3	4831	77.00	79.00	80.00	79.00	84.00
4	2026-07-20 22:27:51	4	4770	88.00	87.00	89.00	87.00	92.00
5	2026-07-20 22:27:51	5	2705	91.00	91.00	91.00	90.00	92.00
6	2026-07-20 22:27:51	6	2612	89.00	92.00	89.00	89.00	91.00
7	2026-07-20 22:27:51	7	2591	96.00	96.00	95.00	96.00	96.00
8	2026-07-20 22:27:51	8	2586	79.00	90.00	81.00	87.00	88.00
9	2026-07-20 22:27:51	9	1986	90.00	89.00	89.00	88.00	91.00
10	2026-07-20 22:27:51	10	1972	97.00	96.00	97.00	96.00	96.00
11	2026-07-20 22:27:51	11	1871	96.00	96.00	97.00	95.00	96.00
12	2026-07-20 22:27:51	12	1856	74.00	82.00	76.00	76.00	86.00
13	2026-07-20 22:27:51	13	1834	91.00	84.00	90.00	83.00	90.00
14	2026-07-20 22:27:51	14	1729	97.00	94.00	95.00	92.00	96.00
15	2026-07-20 22:27:51	15	1593	83.00	76.00	84.00	78.00	84.00
16	2026-07-20 22:27:51	16	1536	87.00	84.00	86.00	86.00	87.00
17	2026-07-20 22:27:51	17	1486	85.00	88.00	88.00	83.00	88.00
18	2026-07-20 22:27:51	18	1472	86.00	79.00	84.00	82.00	87.00
19	2026-07-20 22:27:51	19	1465	96.00	97.00	98.00	99.00	94.00
20	2026-07-20 22:27:51	20	1399	77.00	83.00	82.00	84.00	84.00
21	2026-07-20 22:27:51	21	1308	99.00	99.00	99.00	99.00	98.00
22	2026-07-20 22:27:51	22	1271	82.00	87.00	86.00	87.00	93.00
23	2026-07-20 22:27:51	23	1244	85.00	92.00	89.00	87.00	95.00
24	2026-07-20 22:27:51	24	1199	97.00	98.00	97.00	95.00	98.00
25	2026-07-20 22:27:51	25	1195	91.00	90.00	90.00	91.00	93.00
26	2026-07-20 22:27:51	26	1035	94.00	95.00	94.00	94.00	94.00
27	2026-07-20 22:27:51	27	910	74.00	72.00	73.00	62.00	77.00
28	2026-07-20 22:27:51	28	894	94.00	100.00	96.00	98.00	96.00
29	2026-07-20 22:27:51	29	877	88.00	87.00	89.00	86.00	89.00
30	2026-07-20 22:27:51	30	785	89.00	94.00	90.00	89.00	92.00
31	2026-07-20 22:27:51	31	726	83.00	83.00	83.00	80.00	86.00
32	2026-07-20 22:27:51	32	671	92.00	93.00	93.00	93.00	94.00
33	2026-07-20 22:27:51	33	669	96.00	96.00	96.00	96.00	96.00
34	2026-07-20 22:27:51	34	648	91.00	87.00	91.00	86.00	90.00
35	2026-07-20 22:27:51	35	632	86.00	84.00	85.00	84.00	86.00
36	2026-07-20 22:27:51	36	624	80.00	91.00	87.00	89.00	83.00
37	2026-07-20 22:27:51	37	547	74.00	77.00	76.00	76.00	76.00
38	2026-07-20 22:27:51	38	544	99.00	100.00	99.00	97.00	99.00
39	2026-07-20 22:27:51	39	535	96.00	98.00	99.00	98.00	95.00
40	2026-07-20 22:27:51	40	516	90.00	89.00	90.00	89.00	91.00
41	2026-07-20 22:27:51	41	502	86.00	89.00	85.00	88.00	88.00
42	2026-07-20 22:27:51	42	501	91.00	89.00	91.00	89.00	86.00
43	2026-07-20 22:27:51	43	487	97.00	96.00	97.00	97.00	97.00
44	2026-07-20 22:27:51	44	435	96.00	96.00	96.00	96.00	96.00
45	2026-07-20 22:27:51	45	415	99.00	100.00	100.00	100.00	100.00
46	2026-07-20 22:27:51	46	394	94.00	92.00	92.00	92.00	94.00
47	2026-07-20 22:27:51	47	381	84.00	74.00	81.00	74.00	85.00
48	2026-07-20 22:27:51	48	362	83.00	83.00	82.00	84.00	89.00
49	2026-07-20 22:27:51	49	345	51.00	53.00	53.00	52.00	51.00
50	2026-07-20 22:27:51	50	342	91.00	92.00	92.00	91.00	93.00
1	2026-07-22 17:38:19	1	6691	76.00	75.00	76.00	76.00	75.00
2	2026-07-22 17:38:19	2	5083	95.00	95.00	95.00	95.00	95.00
3	2026-07-22 17:38:19	3	4835	77.00	79.00	80.00	79.00	84.00
4	2026-07-22 17:38:19	4	4778	88.00	87.00	89.00	87.00	92.00
5	2026-07-22 17:38:19	5	2709	91.00	91.00	92.00	91.00	92.00
6	2026-07-22 17:38:19	6	2612	89.00	92.00	90.00	90.00	91.00
7	2026-07-22 17:38:19	7	2593	96.00	96.00	95.00	96.00	96.00
8	2026-07-22 17:38:19	8	2588	79.00	90.00	81.00	87.00	88.00
9	2026-07-22 17:38:19	9	1990	90.00	89.00	89.00	89.00	91.00
10	2026-07-22 17:38:19	10	1972	97.00	96.00	97.00	96.00	96.00
11	2026-07-22 17:38:19	11	1872	96.00	96.00	97.00	95.00	96.00
12	2026-07-22 17:38:19	12	1867	75.00	82.00	76.00	76.00	86.00
13	2026-07-22 17:38:19	13	1834	91.00	84.00	90.00	83.00	90.00
14	2026-07-22 17:38:19	14	1729	97.00	94.00	95.00	92.00	96.00
15	2026-07-22 17:38:19	15	1599	83.00	76.00	84.00	78.00	85.00
16	2026-07-22 17:38:19	16	1541	87.00	84.00	86.00	86.00	87.00
17	2026-07-22 17:38:19	17	1484	85.00	88.00	88.00	83.00	88.00
18	2026-07-22 17:38:19	18	1484	86.00	79.00	84.00	82.00	87.00
19	2026-07-22 17:38:19	19	1465	96.00	97.00	98.00	99.00	94.00
20	2026-07-22 17:38:19	20	1403	77.00	83.00	83.00	85.00	85.00
21	2026-07-22 17:38:19	21	1308	99.00	99.00	99.00	99.00	98.00
22	2026-07-22 17:38:19	22	1276	83.00	87.00	86.00	87.00	93.00
23	2026-07-22 17:38:19	23	1245	85.00	92.00	89.00	87.00	95.00
24	2026-07-22 17:38:19	24	1199	97.00	98.00	97.00	95.00	98.00
25	2026-07-22 17:38:19	25	1196	91.00	90.00	90.00	91.00	92.00
26	2026-07-22 17:38:19	26	1035	94.00	95.00	94.00	94.00	94.00
27	2026-07-22 17:38:19	27	914	74.00	72.00	73.00	62.00	77.00
28	2026-07-22 17:38:19	28	894	94.00	100.00	96.00	98.00	96.00
29	2026-07-22 17:38:19	29	877	88.00	87.00	89.00	86.00	89.00
30	2026-07-22 17:38:19	30	791	89.00	94.00	90.00	89.00	92.00
31	2026-07-22 17:38:19	31	732	83.00	83.00	83.00	81.00	86.00
32	2026-07-22 17:38:19	32	671	92.00	93.00	93.00	93.00	94.00
33	2026-07-22 17:38:19	33	670	96.00	96.00	96.00	96.00	96.00
34	2026-07-22 17:38:19	34	648	91.00	87.00	91.00	86.00	90.00
35	2026-07-22 17:38:19	35	632	86.00	84.00	85.00	84.00	86.00
36	2026-07-22 17:38:19	36	624	80.00	91.00	87.00	89.00	83.00
37	2026-07-22 17:38:19	37	548	74.00	77.00	76.00	76.00	76.00
38	2026-07-22 17:38:19	38	545	99.00	100.00	99.00	97.00	99.00
39	2026-07-22 17:38:19	39	537	96.00	98.00	99.00	98.00	95.00
40	2026-07-22 17:38:19	40	515	90.00	89.00	90.00	89.00	91.00
41	2026-07-22 17:38:19	41	507	86.00	89.00	85.00	88.00	88.00
42	2026-07-22 17:38:19	42	501	91.00	89.00	91.00	89.00	86.00
43	2026-07-22 17:38:19	43	489	97.00	96.00	97.00	97.00	97.00
44	2026-07-22 17:38:19	44	435	96.00	96.00	96.00	96.00	96.00
45	2026-07-22 17:38:19	45	415	99.00	100.00	100.00	100.00	100.00
46	2026-07-22 17:38:19	46	395	94.00	92.00	92.00	92.00	94.00
47	2026-07-22 17:38:19	47	381	84.00	74.00	81.00	74.00	85.00
48	2026-07-22 17:38:19	48	361	83.00	83.00	82.00	84.00	89.00
49	2026-07-22 17:38:19	49	345	51.00	53.00	53.00	52.00	51.00
50	2026-07-22 17:38:19	50	345	91.00	92.00	92.00	91.00	93.00
1	2026-07-23 17:10:04	1	6703	76.00	75.00	76.00	76.00	75.00
2	2026-07-23 17:10:04	2	5094	95.00	95.00	95.00	95.00	95.00
3	2026-07-23 17:10:04	3	4840	77.00	79.00	80.00	79.00	84.00
4	2026-07-23 17:10:04	4	4783	88.00	87.00	88.00	87.00	91.00
5	2026-07-23 17:10:04	5	2715	91.00	91.00	92.00	91.00	92.00
6	2026-07-23 17:10:04	6	2613	89.00	92.00	90.00	90.00	91.00
7	2026-07-23 17:10:04	7	2593	79.00	90.00	81.00	87.00	88.00
8	2026-07-23 17:10:04	8	2593	96.00	96.00	95.00	96.00	96.00
9	2026-07-23 17:10:04	9	1994	90.00	89.00	89.00	89.00	91.00
10	2026-07-23 17:10:04	10	1972	97.00	96.00	97.00	96.00	96.00
11	2026-07-23 17:10:04	11	1880	75.00	82.00	76.00	76.00	86.00
12	2026-07-23 17:10:04	12	1874	96.00	96.00	97.00	95.00	96.00
13	2026-07-23 17:10:04	13	1840	91.00	84.00	90.00	83.00	90.00
14	2026-07-23 17:10:04	14	1729	97.00	94.00	95.00	92.00	96.00
15	2026-07-23 17:10:04	15	1602	83.00	76.00	84.00	78.00	85.00
16	2026-07-23 17:10:04	16	1548	87.00	84.00	86.00	86.00	87.00
17	2026-07-23 17:10:04	17	1493	86.00	88.00	88.00	83.00	88.00
18	2026-07-23 17:10:04	18	1493	86.00	80.00	84.00	82.00	88.00
19	2026-07-23 17:10:04	19	1465	96.00	97.00	98.00	99.00	94.00
20	2026-07-23 17:10:04	20	1405	77.00	83.00	83.00	85.00	85.00
21	2026-07-23 17:10:04	21	1308	99.00	99.00	99.00	99.00	98.00
22	2026-07-23 17:10:04	22	1277	83.00	87.00	86.00	87.00	93.00
23	2026-07-23 17:10:04	23	1248	85.00	92.00	89.00	87.00	95.00
24	2026-07-23 17:10:04	24	1203	91.00	90.00	90.00	91.00	92.00
25	2026-07-23 17:10:04	25	1199	97.00	98.00	97.00	95.00	98.00
26	2026-07-23 17:10:04	26	1035	94.00	95.00	94.00	94.00	94.00
27	2026-07-23 17:10:04	27	919	74.00	71.00	72.00	61.00	77.00
28	2026-07-23 17:10:04	28	894	94.00	100.00	96.00	98.00	96.00
29	2026-07-23 17:10:04	29	877	88.00	87.00	89.00	86.00	89.00
30	2026-07-23 17:10:04	30	794	89.00	94.00	91.00	90.00	92.00
31	2026-07-23 17:10:04	31	738	83.00	83.00	83.00	81.00	86.00
32	2026-07-23 17:10:04	32	671	92.00	93.00	93.00	93.00	94.00
33	2026-07-23 17:10:04	33	670	96.00	96.00	96.00	96.00	96.00
34	2026-07-23 17:10:04	34	648	91.00	87.00	91.00	86.00	90.00
35	2026-07-23 17:10:04	35	635	86.00	84.00	85.00	84.00	86.00
36	2026-07-23 17:10:04	36	624	80.00	91.00	87.00	89.00	83.00
37	2026-07-23 17:10:04	37	548	74.00	77.00	76.00	76.00	76.00
38	2026-07-23 17:10:04	38	545	99.00	100.00	99.00	97.00	99.00
39	2026-07-23 17:10:04	39	537	96.00	98.00	99.00	98.00	95.00
40	2026-07-23 17:10:04	40	516	90.00	89.00	90.00	89.00	91.00
41	2026-07-23 17:10:04	41	509	86.00	89.00	85.00	88.00	88.00
42	2026-07-23 17:10:04	42	501	91.00	89.00	91.00	89.00	86.00
43	2026-07-23 17:10:04	43	491	97.00	96.00	97.00	97.00	97.00
44	2026-07-23 17:10:04	44	435	96.00	96.00	96.00	96.00	96.00
45	2026-07-23 17:10:04	45	415	99.00	100.00	100.00	100.00	100.00
46	2026-07-23 17:10:04	46	394	94.00	92.00	92.00	92.00	94.00
47	2026-07-23 17:10:04	47	382	84.00	74.00	81.00	74.00	85.00
48	2026-07-23 17:10:04	48	361	83.00	83.00	82.00	84.00	89.00
49	2026-07-23 17:10:04	49	346	87.00	86.00	87.00	86.00	89.00
50	2026-07-23 17:10:04	50	345	51.00	53.00	53.00	52.00	51.00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id_group, id_label, name, other_name, status, debut_date, id_parent_group) FROM stdin;
1	1	BTS	Bangtan Bulletproof Boys Scouts	ACTIVE	2013-06-13	\N
2	2	Stray Kids	SKZ	ACTIVE	2018-03-25	\N
3	3	BLACKPINK	ブラックピンク	ACTIVE	2016-08-08	\N
4	\N	TWICE	トゥワイス	ACTIVE	2015-10-20	\N
5	4	ENHYPEN	エンハイフン	ACTIVE	2020-11-30	\N
6	5	EXO	\N	ACTIVE	2012-04-08	\N
7	1	SEVENTEEN	セブンティーン	ACTIVE	2015-05-26	\N
8	5	Red Velvet	レッドベルベット	ACTIVE	2014-08-01	\N
9	1	TOMORROW X TOGETHER	TXT	ACTIVE	2019-03-04	\N
10	6	GOT7	\N	ACTIVE	2014-01-16	\N
11	7	ATEEZ	エイティーズ	ACTIVE	2018-10-24	\N
12	5	aespa	埃斯帕	ACTIVE	2020-11-17	\N
13	8	ITZY	イッチ	ACTIVE	2019-02-12	\N
15	9	LE SSERAFIM	ルセラフィム	ACTIVE	2022-05-02	\N
16	1	CORTIS	Color Outside The Lines	ACTIVE	2025-08-18	\N
17	3	BABYMONSTER	BAEMON	ACTIVE	2023-11-27	\N
18	4	ILLIT	アイリット	ACTIVE	2024-03-25	\N
19	10	MONSTA X	モンスタエックス	ACTIVE	2015-05-14	\N
20	11	i-dle	(G) i-dle	ACTIVE	2018-05-02	\N
21	5	SHINee	\N	ACTIVE	2008-05-25	\N
22	10	IVE	アイヴ	ACTIVE	2021-12-01	\N
23	5	Girls' Generation	SNSD	ACTIVE	2007-08-05	\N
24	12	Wanna One	ワナワン	DISBANDED	2017-08-07	\N
25	1	NewJeans	NJZ	HIATUS	2022-07-22	\N
26	5	NCT	Neo Culture Technology	ACTIVE	2016-04-09	\N
27	1	KATSEYE	キャッツアイ	ACTIVE	2024-06-28	\N
30	\N	NMIXX	エンミックス	ACTIVE	2022-02-22	\N
31	5	Hearts2Hearts	H2H	ACTIVE	2025-02-24	\N
32	14	Dreamcatcher	MINX	ACTIVE	2017-01-13	\N
33	15	P1Harmony	P1H	ACTIVE	2020-10-28	\N
35	16	LOONA	LOOΠΔ	HIATUS	2018-08-19	\N
36	17	MAMAMOO	\N	ACTIVE	2014-06-19	\N
37	9	GFRIEND	\N	DISBANDED	2015-01-16	\N
38	18	ASTRO	アストロ	ACTIVE	2016-02-23	\N
39	3	BIGBANG	\N	ACTIVE	2006-08-19	\N
40	1	BOYNEXTDOOR	ボーイネクストドア	ACTIVE	2023-05-30	\N
41	19	LNGSHOT	エルエヌジーショット	ACTIVE	2026-01-13	\N
42	20	iKON	\N	ACTIVE	2015-09-15	\N
43	21	XLOV	艾克斯爱	ACTIVE	2025-01-07	\N
44	22	ZEROBASEONE	ZB1	ACTIVE	2023-07-10	\N
45	12	IZ*ONE	アイズワン	DISBANDED	2018-10-29	\N
46	1	&TEAM	アンドチーム	ACTIVE	2022-12-07	\N
47	23	EVERGLOW	\N	ACTIVE	2019-03-18	\N
48	\N	tripleS	트리플S	ACTIVE	2023-02-13	\N
49	5	SUPER JUNIOR	スーパージュニア	ACTIVE	2005-11-06	\N
50	24	XG	Xtraordinary Genes	ACTIVE	2022-03-18	\N
29	5	NCT Dream	\N	ACTIVE	2016-08-25	26
34	5	NCT U	\N	ACTIVE	2016-04-09	26
51	2	3RACHA	\N	ACTIVE	2018-03-25	2
52	\N	MISAMO	ミサモ	ACTIVE	2023-07-26	4
53	5	EXO-K	\N	ACTIVE	2012-04-08	6
54	5	EXO-M	\N	HIATUS	2012-04-08	6
55	5	EXO-SC	\N	ACTIVE	2019-07-22	6
56	1	V8	\N	ACTIVE	2026-06-29	7
57	1	Hoshi X Woozi	\N	ACTIVE	2025-03-10	8
58	1	DK X Seungkwan	\N	ACTIVE	2026-01-12	8
59	1	S.Coups X Mingyu	\N	ACTIVE	2025-09-29	8
60	1	BSS	\N	ACTIVE	2018-03-21	8
61	1	SVT PERFORMANCE Team	\N	ACTIVE	2015-05-26	8
62	1	SVT HIPHOP Team	\N	ACTIVE	2015-05-26	8
63	1	Jeonghan X Wonwoo	\N	ACTIVE	2024-06-17	8
64	1	SVT Leaders	\N	ACTIVE	2017-09-24	8
65	1	SVT VOCAL Team	\N	ACTIVE	2015-05-26	8
66	5	Red Velvet - IRENE & SEULGI	\N	ACTIVE	2020-07-06	8
67	6	JUS2	\N	HIATUS	2019-03-05	10
68	6	JJ Project	\N	HIATUS	2012-05-20	10
69	10	SHOWNU X HYUNGWON	ショヌXヒョンウォン	ACTIVE	2023-07-25	19
70	5	Girls' Generation-TTS	少女時代-テティソ	HIATUS	2012-04-29	23
71	5	Girls' Generation - Oh!GG	少女時代-Oh!GG	HIATUS	2018-09-05	23
72	5	NCT WISH	エヌシーティー ウィッシュ	ACTIVE	2024-02-21	26
73	5	NCT DOJAEJUNG	\N	ACTIVE	2023-04-17	26
74	5	WayV	威神V	ACTIVE	2019-01-17	26
75	5	NCT JNJM	\N	ACTIVE	2026-02-23	26
76	14	UAU	\N	ACTIVE	2025-05-28	32
77	16	LOONA 1/3	LOOΠΔ 1/3	HIATUS	2017-03-12	35
78	16	LOONA yyxy	yyxy	HIATUS	2018-05-30	35
79	17	MAMAMOO+	\N	HIATUS	2022-08-30	36
80	18	ZOONIZINI	ズニジニ	ACTIVE	2025-08-13	38
81	18	MOONBIN & SANHA	ムンビン&サナ	DISBANDED	2020-09-14	38
82	18	Jinjin & Rocky	ジンジン & ラキ	DISBANDED	2022-01-17	38
83	3	GD & TOP	\N	DISBANDED	2010-12-24	39
84	20	Double B	\N	DISBANDED	2015-11-16	42
85	\N	EVOLution	\N	DISBANDED	2023-10-11	48
86	\N	Visionary Vision	VV	DISBANDED	2024-10-23	48
87	\N	LOVElution	ラブリューション	DISBANDED	2023-08-17	48
88	\N	moon	\N	ACTIVE	2025-11-24	48
89	\N	zenith	\N	ACTIVE	2025-11-24	48
90	\N	NXT	\N	DISBANDED	2023-12-23	48
91	\N	Glow	\N	DISBANDED	2024-06-21	48
92	\N	neptune	\N	ACTIVE	2025-11-24	48
93	\N	ACID EYES	\N	DISBANDED	2023-06-06	48
94	\N	Aria	\N	DISBANDED	2024-01-15	48
95	\N	Hatchi!	ハッチ!	ACTIVE	2024-11-20	48
96	\N	sun	\N	ACTIVE	2025-11-24	48
97	\N	+(KR)ystal Eyes	クリスタル・アイズ	DISBANDED	2023-05-04	48
98	\N	Acid Angel from Asia	アシッド・エンジェル・フロム・エイジア	DISBANDED	2022-10-28	48
99	\N	Alphie	\N	DISBANDED	2025-09-03	48
100	5	SUPER JUNIOR-83z	\N	ACTIVE	2026-07-13	50
101	5	SUPER JUNIOR-L.S.S.	\N	ACTIVE	2023-07-05	50
102	5	SUPER JUNIOR-K.R.Y.	\N	ACTIVE	2006-11-05	50
103	5	Super Junior-M	\N	HIATUS	2008-04-08	50
104	5	SUPER JUNIOR-D&E	\N	ACTIVE	2011-12-16	50
105	5	SUPER JUNIOR-H	\N	HIATUS	2008-05-03	50
106	5	SUPER JUNIOR-T	\N	HIATUS	2007-02-23	50
14	5	NCT 127	エヌシーティー 127	ACTIVE	2016-07-07	26
28	13	EXO-CBX	CBX	ACTIVE	2016-10-31	6
\.


--
-- Data for Name: hiatus_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hiatus_groups (id_group, hiatus_year, hiatus_reason) FROM stdin;
25	2025	\N
66	2021	\N
69	2017	\N
76	2023	\N
102	2023	\N
104	2023	\N
35	2023	\N
54	2023	\N
67	2021	\N
68	2021	\N
70	2017	\N
71	2018	\N
77	2023	\N
78	2023	\N
79	2023	\N
103	2023	\N
105	2023	\N
106	2023	\N
\.


--
-- Data for Name: idols; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.idols (id_idol, stage_name, full_name, birthday, birth_adm_area, birth_country, height) FROM stdin;
1	Jin	Kim Seok-jin	1992-12-04	Gyeonggi-do	South Korea	180.00
2	Suga	Min Yoongi	1993-03-09	Daegu	South Korea	174.00
3	J-hope	Jung Ho-seok	1994-02-18	Gwangju	South Korea	177.00
4	RM	Kim Namjoon	1994-09-12	Goyang	South Korea	181.00
5	Jimin	Park Jimin	1995-10-13	Busan	South Korea	174.00
6	V	Kim Taehyung	1995-12-30	Daegu	South Korea	179.00
7	Jungkook	Jeon Jungkook	1997-09-01	Busan	South Korea	177.00
8	Bang Chan	Christopher Chahn Bahng	1997-10-03	Seoul	South Korea	171.00
9	Lee Know	Lee Min-ho	1998-10-25	Gimpo	South Korea	172.00
10	Changbin	Seo Chang-bin	1999-08-11	Yongin	South Korea	167.00
11	Hyunjin	Hwang Hyun-jin	2000-03-20	Seoul	South Korea	179.00
12	Han	Han Ji-sung	2000-09-14	Incheon	South Korea	169.00
13	Felix	Felix Yongbok Lee	2000-09-15	Sydney	Australia	171.00
14	Seungmin	Kim Seung-min	2000-09-22	Seoul	South Korea	178.00
15	I.N	Yang Jeong-in	2001-02-08	Busan	South Korea	172.00
16	Jisoo	Kim Ji-soo	1995-01-03	Gyenggi-do	South Korea	162.00
17	Jennie	Kim Jennie	1996-01-16	Seongnam	South Korea	163.00
18	Rosé	Roseanne Park	1997-02-11	Auckland	New Zealand	168.00
19	Lisa	Lalisa Manobal	1997-03-27	Buriram	Thailand	167.00
20	Nayeon	Im Na-yeon	1995-09-22	Seoul	South Korea	163.00
21	Jeongyeon	Yoo Jeong-yeon	1996-11-01	Suwon	South Korea	168.00
22	Momo	Hirai Momo	1996-11-09	Kyoto	Japan	163.00
23	Sana	Minatozaki Sana	1996-12-29	Osaka	Japan	164.00
24	Jihyo	Park Ji-hyo	1997-02-01	Gyeonggi-do	South Korea	162.00
25	Mina	Myōi Mina	1997-03-24	Texas	United States	163.00
26	Dahyun	Kim Da-hyun	1998-05-28	Gyeonggi-do	South Korea	161.00
27	Chaeyoung	Son Chae-young	1999-04-23	Seoul	South Korea	159.00
28	Tzuyu	Chou Tzuyu	1999-06-14	Tainan	Taiwan	170.00
29	Jay	Park Jong Seong	2002-04-20	Washington	United States	179.00
30	Jake	Sim Jaeyun	2002-11-15	Seoul	South Korea	175.00
31	Sunghoon	Park Sung Hoon	2002-12-08	Gyeonggi-do	South Korea	181.00
32	Sunoo	Kim Seon Woo	2003-06-24	Gyeonggi	South Korea	175.00
33	Jungwon	Yang Jung Won	2004-02-09	Seoul	South Korea	174.00
34	Ni-ki	Nishimura Riki	2005-12-09	Okayama	Japan	186.00
35	Xiumin	Kim Min-seok	1990-03-26	Gyeonggi Province	South Korea	173.00
36	Suho	Kim Jun-myeon	1991-05-22	Seoul	South Korea	173.00
37	Lay	Zhang Yixing	1991-10-07	Hunan	China	177.00
38	Baekhyun	Byun Baek-hyun	1992-05-06	Gyeonggi-do	South Korea	174.00
39	Chen	Kim Jong-dae	1992-09-21	Gyeonggi	South Korea	173.00
40	Chanyeol	Park Chan-yeol	1992-11-27	Seoul	South Korea	185.00
41	D.O.	Do Kyung-soo	1993-01-12	Gyeonggi Province	South Korea	173.00
42	Kai	Kim Jong-in	1994-01-14	South Jeolla	South Korea	182.00
43	Sehun	Oh Se-hun	1994-04-12	Seoul	South Korea	183.00
44	S.Coups	Choi Seung Cheol	1995-08-08	Daegu	South Korea	178.00
45	Jeonghan	Yoon Jeong Han	1995-10-04	Gyeonggi	South Korea	178.00
46	Joshua	Joshua Jisoo Hong	1995-12-30	California	United States	178.00
47	Jun	Wen Junhui	1996-06-10	Guangdong	China	182.00
48	Hoshi	Kwon Soonyoung	1996-06-15	South Korea	South Korea	177.00
49	Wonwoo	Jeon Wonwoo	1996-07-17	Gyeongsangnam-do	South Korea	182.00
50	Woozi	Lee Jihoon	1996-11-22	Busan	South Korea	166.00
51	DK	Lee Seokmin	1997-02-18	Seoul	South Korea	179.00
52	Mingyu	Kim Mingyu	1997-04-06	Gyeonggi-do	South Korea	187.00
53	The8	Xu Minghao	1997-11-07	Liaoning	China	180.00
54	Seungkwan	Boo Seung Kwan	1998-01-16	Jeju	South Korea	174.00
55	Vernon	Hansol Vernon Chwe	1998-02-18	New York	United States	178.00
56	Dino	Lee Chan	1999-02-11	Jeollabuk-do	South Korea	173.00
57	Irene	Bae Ju-hyun	1991-03-29	Daegu	South Korea	158.00
58	Seulgi	Kang Seul Gi	1994-02-10	Gyeonggi-do	South Korea	161.00
59	Wendy	Son Seung-wan	1994-02-21	Seoul	South Korea	159.00
60	Joy	Park Soo Young	1996-09-03	Jeju Island	South Korea	167.00
61	Yeri	Kim Ye Rim	1999-03-05	Seoul	South Korea	158.00
62	Yeonjun	Choi Yeon-jun	1999-09-13	Seoul	South Korea	181.00
63	Soobin	Choi Soobin	2000-12-05	Gyeonggi-do	South Korea	186.00
64	Beomgyu	Choi Beomgyu	2001-03-13	Daegu	South Korea	179.00
65	Taehyun	Kang Tae-hyun	2002-02-05	Seoul	South Korea	177.00
66	Huening Kai	Kai Kamal Huening	2002-08-14	Hawaii	United States	183.00
67	Mark	Mark Yi En Tuan	1993-09-04	California	United States	175.00
68	Jay B	Lim Jae Beom	1994-01-06	Siheung	South Korea	179.00
69	Jackson	Jackson Wang	1994-03-28	Hong Kong	Hong Kong	174.00
70	Jinyoung	Park Jin Young	1994-09-22	Gyeongsangnam-do	South Korea	178.00
71	Youngjae	Choi Young Jae	1996-09-17	Mokpo	South Korea	177.00
72	BamBam	Kunpimook Bhuwakul	1997-05-02	Bangkok	Thailand	178.00
73	Yugyeom	Kim Yu Gyeom	1997-11-17	Seoul	South Korea	183.00
74	Seonghwa	Park Seong-hwa	1998-04-03	South Gyeongsang	South Korea	178.00
75	Hongjoong	Kim Hong Joong	1998-11-07	Gyeonggi-do	South Korea	172.00
76	Yunho	Jeong Yun-ho	1999-03-23	Gwangju	South Korea	186.00
77	Yeosang	Kang Yeo-sang	1999-06-15	Incheon	South Korea	175.00
78	San	Choi San	1999-07-10	Gyeongsangnam-do	South Korea	177.00
79	Mingi	Song Min-gi	1999-08-09	Gyeonggi-do	South Korea	184.00
80	Wooyoung	Jung Woo-young	1999-11-26	Ilsan	South Korea	173.00
81	Jongho	Choi Jong-ho	2000-10-12	Nowon-gu	South Korea	176.00
82	Karina	Yu Ji-min	2000-04-11	Gyeonggi-do	South Korea	168.00
83	Giselle	Uchinaga Aeri	2000-10-30	Tokyo	Japan	163.00
84	Winter	Kim Min-jeong	2001-01-01	South Korea	South Korea	163.00
85	Ningning	Ning Yizhuo	2002-10-23	China	China	161.00
86	Yeji	Hwang Ye-ji	2000-05-26	Seoul	South Korea	167.00
87	Lia	Choi Ji-su	2000-07-21	Incheon	South Korea	162.00
88	Ryujin	Shin Ryu-jin	2001-04-17	Gangwon	South Korea	164.00
89	Chaeryeong	Lee Chae-ryeong	2001-06-05	Yongin	South Korea	167.00
90	Yuna	Shin Yu-na	2003-12-09	Gyeonggi-do	South Korea	170.00
91	Johnny	Johnny Suh	1995-02-09	Illinois	United States	185.00
92	Taeyong	Lee Tae-yong	1995-07-01	Seoul	South Korea	175.00
93	Yuta	Nakamoto Yuta	1995-10-26	Osaka	Japan	176.00
94	Doyoung	Kim Dong-young	1996-02-01	Seoul	South Korea	178.00
95	Jaehyun	Jeong Yoon Oh	1997-02-14	Seoul	South Korea	180.00
96	Jungwoo	Kim Jung Woo	1998-02-19	Gunpo	South Korea	180.00
97	Haechan	Lee Dong-hyuck	2000-06-06	Seoul	South Korea	174.00
98	Sakura	Miyawaki Sakura	1998-03-19	Kagoshima	Japan	163.00
99	Kim Chaewon	Kim Chae-won	2000-08-01	Seoul	South Korea	164.00
100	Huh Yunjin	Huh Yun-Jin	2001-10-08	Seoul	South Korea	172.00
101	Kazuha	Nakamura Kazuha	2003-08-09	Kochi Prefecture	Japan	170.00
102	Hong Eunchae	Hong Eun-chae	2006-11-10	Seoul	South Korea	169.00
103	James	Zhao Yufan	2005-10-14	Hong Kong Special Administrative Region	Hong Kong	178.00
104	Juhoon	Kim Juhoon	2008-01-03	Seoul	South Korea	175.00
105	Martin	Martin Edwards Park	2008-03-20	South Korea	South Korea	193.00
106	Seonghyeon	Eom Seong-hyeon	2009-01-13	Daejeon	South Korea	175.00
107	Keonho	Ahn Geon-ho	2009-02-14	Gyeonggi Province	South Korea	176.00
108	Ruka	Kawai Ruka	2002-03-20	Yamaguchi Prefecture	Japan	158.00
109	Pharita	Pharita Boonpakdeethaveeyod	2005-08-26	Bangkok	THAILAND	167.00
110	Asa	Enami Asa	2006-04-17	Tokyo	Japan	161.00
111	Ahyeon	Jung A-hyeon	2007-04-11	Gangwon-do	South Korea	163.00
112	Rami	Shin Ha-ram	2007-10-17	Seoul	South Korea	172.00
113	Rora	Lee Da-in	2008-08-14	Gangwon-do	South Korea	167.00
114	Chiquita	Riracha Phondechaphiphat	2009-02-17	Nakhon Ratchasima	Thailand	165.00
115	Yunah	Noh Yun-ah	2004-01-15	Chungcheongbuk-do	South Korea	168.00
116	Minju	Park Min-ju	2004-05-11	Gyeonggi	South Korea	163.00
117	Moka	Sakai Moka	2004-10-08	Fukuoka	Japan	162.00
118	Wonhee	Lee Won-hee	2007-06-26	Busan	South Korea	162.00
119	Iroha	Hokazono Iroha	2008-02-04	Tokyo	Japan	158.00
120	Shownu	Sohn Hyun-woo	1992-06-18	Donbonggu	South Korea	181.00
121	Minhyuk	Lee Min-hyuk	1993-11-03	Gwanju	South Korea	180.00
122	Kihyun	Yoo Ki-hyun	1993-11-22	Goyang	South Korea	175.00
123	Hyungwon	Chae Hyung-won	1994-01-15	Gwangju	South Korea	183.00
124	Joohoney	Lee Joo-heon	1994-10-06	Seoul	South Korea	179.00
125	I.M	Im Chang-kyun	1996-01-26	Gwangju	South Korea	175.00
126	Miyeon	Cho Mi-yeon	1997-01-31	Incheon	South Korea	161.00
127	Minnie	Nicha Yontararak	1997-10-23	Bangkok	Thailand	167.00
128	Soyeon	Jeon So-yeon	1998-08-26	Seoul	South Korea	157.00
129	Yuqi	Song Yu Qi	1999-09-23	Beijing	China	163.00
130	Shuhua	Yeh Shuhua	2000-01-06	Taoyuan	Taiwan	161.00
131	Onew	Lee Jin-ki	1989-12-14	Gyeonggi-do	South Korea	177.00
132	Key	Kim Ki-bum	1991-09-23	Daegu	South Korea	175.00
133	Minho	Choi Min-ho	1991-12-09	Incheon	South Korea	184.00
134	Taemin	Lee Tae-min	1993-07-18	Seoul	South Korea	174.00
135	Gaeul	Kim Ga Eul	2002-09-24	Incheon	South Korea	164.00
136	Yujin	An Yu-jin	2003-09-01	North Chungcheong Province	South Korea	173.00
137	Rei	Naoi Rei	2004-02-03	Aichi Prefecture	Japan	170.00
138	Wonyoung	Jang Won-young	2004-08-31	Seoul	South Korea	173.00
139	Liz	Kim Ji-won	2004-11-21	Jeju	South Korea	171.00
140	Leeseo	Lee Hyun-seo	2007-02-21	Seoul	South Korea	166.00
141	Taeyeon	Kim Tae-yeon	1989-03-09	Jeonju	South Korea	160.00
142	Sunny	Lee Soon Kyu	1989-05-15	California	United States	158.00
143	Tiffany Young	Stephanie Young Hwang	1989-08-01	California	United States	163.00
144	Hyoyeon	Kim Hyo-yeon	1989-09-22	Incheon	South Korea	161.00
145	Yuri	Kwon Yu-ri	1989-12-05	Gyeonggi-do	South Korea	168.00
146	Sooyoung	Choi Soo Young	1990-02-10	Seoul	South Korea	172.00
147	Yoona	Im Yoon Ah	1990-05-30	Seoul	South Korea	168.00
148	Seohyun	Seo Ju-hyun	1991-06-28	Seoul	South Korea	170.00
149	Jisung	Yoon Ji-sung	1991-03-08	Wonju	South Korea	175.00
150	Ha Sung Woon	Ha Sung Woon	1994-03-22	Goyang	South Korea	168.00
151	Hwang Min Hyun	Hwang Min-Hyun	1995-08-09	Busan	South Korea	181.00
152	Seongwu	Ong Seongwu	1995-08-25	Incheon	South Korea	179.00
153	Kim Jaehwan	Kim Jae-hwan	1996-05-27	Seoul	South Korea	175.00
154	Kang Daniel	Kang Daniel	1996-12-10	Busan	South Korea	\N
155	Park Jihoon	Park Ji-hoon	1999-05-29	Seoul	South Korea	173.00
156	Woojin	Park Woojin	1999-11-02	Busan	South Korea	176.00
157	Jinyoung	Bae Jin-young	2000-05-10	Seoul	South Korea	178.00
158	Daehwi	Lee Dae-hwi	2001-01-29	Seoul	South Korea	173.00
159	Kuanlin	Lai Kuan Lin	2001-09-23	Taipei	Taiwan	183.00
160	Minji	Kim Min-ji	2004-05-07	Gangwon-do	South Korea	169.00
161	Hanni	Hanni Phạm	2004-10-06	Melbourne	Australia	162.00
162	Haerin	Kang Hae-rin	2006-05-15	Gyeonggi-do	South Korea	165.00
163	Hyein	Lee Hye-in	2008-04-21	Incheon	South Korea	170.00
164	Kun	Qián Kūn	1996-01-01	Fujian	China	176.00
165	Ten	Chittaphon Leechaiyapornkul	1996-02-27	Bangkok	Thailand	172.00
166	Xiaojun	Xiao De Jun	1999-08-08	Guangdong	China	170.00
167	Hendery	Wong Kun-Hang	1999-09-28	Macau	Macau	175.00
168	Renjun	Huang Renjun	2000-03-23	Jilin	China	170.00
169	Jeno	Lee Je-no	2000-04-23	Incheon	South Korea	178.00
170	Jaemin	Na Jae-min	2000-08-13	Seoul	South Korea	177.00
171	YangYang	Liu YangYang	2000-10-10	New Taipei City	Taiwan	173.00
172	Chenle	Zhong Chenle	2001-11-22	Shanghai	China	179.00
173	Jisung	Park Ji-sung	2002-02-05	Seoul	South Korea	180.00
174	Sion	Oh Si-on	2002-05-11	Jeollanam-do	South Korea	179.00
175	Riku	Maeda Riku	2003-06-28	Fukui	Japan	176.00
176	Yushi	Tokuno Yūshi	2004-04-05	Tokyo	Japan	175.00
177	Jaehee	Kim Daeyoung	2005-06-21	Daegu	South Korea	185.00
178	Ryo	Hirose Ryō	2007-08-04	Kyoto	Japan	165.00
179	Sakuya	Fujinaga Sakuya	2007-11-18	Saitama	Japan	176.00
180	Manon	Meret Manon Sarpong Bannerman	2002-06-26	Lucerne	Switzerland	166.00
181	Sophia	Sophia Elizabeth Guevara Laforteza	2002-12-31	New York	United States	167.00
182	Daniela	Daniela Andrea Avanzini Llorente	2004-07-01	Georgia	United States	163.00
183	Lara	Lara Rajagopalan	2005-11-03	Connecticut	United States	167.00
184	Megan	Megan Meiyok Skiendiel	2006-02-10	Hawaii	United States	169.00
185	Yoonchae	Jeong Yoon-chae	2007-12-06	Seoul	South Korea	170.00
186	Lily	Lily Jin Park Morrow	2002-10-17	Victoria	Australia	164.00
187	Haewon	Oh Hae-won	2003-02-25	Incheon	South Korea	163.00
188	Sullyoon	Seol Yoon-a	2004-01-26	Daejeon	South Korea	168.00
189	Bae	Bae Jin-sol	2004-12-28	Gyeongsangnam-do	South Korea	170.00
190	Jiwoo	Kim Ji-woo	2005-04-13	Gyeonggi-do	South Korea	161.00
191	Kyujin	Jang Kyu-jin	2006-05-26	Gyeonggi-do	South Korea	164.00
192	Carmen	Nyoman Ayu Carmenita	2006-03-28	Bali	Indonesia	168.00
193	Jiwoo	Choi Ji-woo	2006-09-07	Seoul	South Korea	169.00
194	Yuha	Yu Ha-ram	2007-04-12	Gangwon-do	South Korea	164.00
195	Stella	Kim Da-hyun	2007-06-18	Ulsan	South Korea	167.00
196	Juun	Kim Ju-eun	2008-12-03	Gyeonggi-do	South Korea	165.00
197	A-na	Roh Yu-na	2008-12-20	Seoul	South Korea	171.00
198	Ian	Jeong Lee-an	2009-10-09	Seoul	South Korea	165.00
199	Ye-on	Kim Na-yeon	2010-04-19	Gyeongsangnam-do	South Korea	166.00
200	JiU	Kim Min-ji	1994-05-17	Daejeon	South Korea	167.00
201	SuA	Kim Bo-ra	1994-08-10	Gyeongsangnam-do	South Korea	161.00
202	Siyeon	Lee Si-yeon	1995-10-01	Daegu	South Korea	166.00
203	Handong	Hán Dōng	1996-03-26	Hubei	China	166.00
204	Yoohyeon	Kim Yoo-hyun	1997-01-07	Incheon	South Korea	168.00
205	Dami	Lee Yu-bin	1997-03-07	Seoul	South Korea	163.00
206	Gahyun	Lee Ga-hyun	1999-02-03	Seongnam	South Korea	160.00
207	Theo	Choi Tae Yang	2001-07-01	Daejeon	South Korea	180.00
208	Keeho	Yoon Kee-ho	2001-09-27	Ontario	Canada	177.00
209	Jiung	Choi Ji Ung	2001-10-07	Anyang	South Korea	178.00
210	Intak	Hwang In Tak	2003-08-31	Yangju	South Korea	180.00
211	Soul	Haku Shota	2005-02-01	Saitama Prefecture	Japan	177.00
212	Jongseob	Kim Jong Seob	2005-11-19	Gyeonggi	South Korea	177.00
213	ViVi	Wong Kahei	1996-12-09	New Territories	Hong Kong	158.00
214	Yves	Ha Soo-young	1997-05-24	Busan	South Korea	166.00
215	JinSoul	Jeong Jin-sol	1997-06-13	Seoul	South Korea	165.00
216	HaSeul	Cho Ha-seul	1997-08-18	South Jeolla Province	South Korea	158.00
217	Kim Lip	Kim Jung-eun	1999-02-10	North Chungcheong Province	South Korea	163.00
218	HeeJin	Jeon Hee-jin	2000-10-19	Daejeon	South Korea	161.00
219	HyunJin	Kim Hyun-jin	2000-11-15	North Jeolla Province	South Korea	163.00
220	Go Won	Park Chae-won	2000-11-19	Gyeonggi-do	South Korea	160.00
221	Choerry	Choi Ye-rim	2001-06-04	Gyeonggi-do	South Korea	161.00
222	HyeJu	Son Hye-ju	2001-11-13	Seoul	South Korea	165.00
223	YeoJin	Im Yeo-Jin	2002-11-11	Daegu	South Korea	151.00
224	Solar	Kim Yong Sun	1991-02-21	Seoul	South Korea	160.00
225	Moonbyul	Moon Byul-yi	1992-12-22	Bucheon	South Korea	163.00
226	Wheein	Jung Whee-in	1995-04-17	Jeonju	South Korea	159.00
227	Hwasa	Ahn Hye-jin	1995-07-23	Jeollabuk-do	South Korea	160.00
228	Sowon	Kim So-jung	1995-12-07	Seoul	South Korea	173.00
229	Yerin	Jung Ye-rin	1996-08-19	Incheon	South Korea	167.00
230	Eunha	Jung Eun Bi	1997-05-30	Seoul	South Korea	163.00
231	Yuju	Choi Yu-na	1997-10-04	Ilsan	South Korea	169.00
232	SinB	Hwang Eun-bi	1998-06-03	Cheongju	South Korea	166.00
233	Umji	Kim Ye Won	1998-08-19	Incheon	South Korea	165.00
234	MJ	Myeong-jun	1994-03-05	Gyeonggi Province	South Korea	175.00
235	Jinjin	Park Jin Woo	1996-03-15	Gyeonggi-do	South Korea	174.00
236	Cha Eunwoo	Lee Dong-min	1997-03-30	Gyeonggi Province	South Korea	183.00
237	Sanha	Yoon San Ha	2000-03-21	Seoul	South Korea	184.00
238	Taeyang	Dong Yong Bae	1988-05-18	Gyeonggi-do	South Korea	173.00
239	G-Dragon	Kwon Ji-yong	1988-08-18	Seoul	South Korea	177.00
240	Daesung	Kang Daesung	1989-04-26	Incheon	South Korea	178.00
241	Sungho	Park Sung Ho	2003-09-04	Gangwon-do	South Korea	174.00
242	Riwoo	Lee Sang Hyeok	2003-10-22	Seoul	South Korea	170.00
243	Jaehyun	Myung Jae Hyun	2003-12-04	Seoul	South Korea	177.00
244	Taesan	Han Dong-Min	2004-08-10	Gwangju	South Korea	179.00
245	Leehan	Kim Dong Hyun	2004-10-20	Busan	South Korea	180.00
246	Woonhak	Kim Woon-hak	2006-11-29	Gyeonggi-do	South Korea	182.00
247	Ohyul	Kwon Oh-yul	2006-01-21	Gyeonggi-do	South Korea	182.00
248	Ryul	Kim Ryul	2006-09-18	Busan	South Korea	180.00
249	Woojin	Jung Woo-jin	2008-03-08	Seoul	South Korea	178.00
250	Louis	Louis Elliot Jiho Jourdain Lim	2010-05-01	Seoul	South Korea	186.00
251	Jay	Kim Jinhwan	1994-02-07	Jeju Island	South Korea	165.00
252	Song	Song Yun-hyeong	1995-02-08	Seoul	South Korea	178.00
253	Bobby	Kim Ji-won	1995-12-21	Seoul	South Korea	180.00
254	DK	Kim Donghyuk	1997-01-03	Seoul	South Korea	175.00
255	Ju-ne	Koo Junhoe	1997-03-31	Seoul	South Korea	183.00
256	Chan	Jung Chanwoo	1998-01-26	Gyeonggi	South Korea	184.00
257	Wumuti	Wúmùtí Tǔ'ěrxùn/Umut Tursun	1999-07-07	Xinjiang	China	175.00
258	Rui	Chen Kuan-jui	2000-12-28	Taipei	Taiwan	175.00
259	Hyun	Kim Jin-Hyung	2002-07-26	Gwangju	South Korea	185.00
260	Haru	Kato Haru	2006-02-18	Hyogo	Japan	168.00
261	Kim Ji Woong	Kim Ji-woong	1998-12-14	Gangwon-do	South Korea	181.00
262	Sung Han Bin	Sung Han-bin	2001-06-13	Chungcheongnam-do	South Korea	180.00
263	Seok Matthew	Seok Matthew	2002-05-28	Vancouver	Canada	170.00
264	Kim Tae Rae	Kim Tae-rae	2002-07-14	Chungcheongnam-do	South Korea	174.00
265	Park Gun Wook	Park Gun-wook	2005-01-10	Gyeonggi-do	South Korea	184.00
266	Kwon Eunbi	Kwon Eun-bi	1995-09-27	Seoul	South Korea	158.00
267	Kang Hyewon	Kang Hye-won	1999-07-05	Busan	South Korea	163.00
268	Yena	Choi Ye-na	1999-09-29	Seoul	South Korea	162.00
269	Lee Chae Yeon	Lee Chae Yeon	2000-01-11	Yongin	South Korea	167.00
270	Minju	Kim Min-ju	2001-02-05	Seoul	South Korea	164.00
271	Nako	Yabuki Nako	2001-06-18	Tokyo	Japan	150.00
272	Hitomi	Honda Hitomi	2001-10-06	Tochigi	Japan	160.00
273	Jo Yuri	Jo Yu-ri	2001-10-22	Busan	South Korea	163.00
274	K	Koga Yudai	1997-10-21	Tokyo	Japan	187.00
275	Fuma	Murata Fūma	1998-06-29	Shizuoka	Japan	180.00
276	Nicholas	Wang Yixiang	2002-07-09	New Taipei City	Taiwan	175.00
277	EJ	Byun Eui Joo	2002-09-07	Gyeonggi-do	South Korea	184.00
278	Yuma	Nakakita Yūma	2004-02-07	Hyogo	Japan	175.00
279	Jo	Asakura Jo	2004-07-08	Kanagawa	Japan	185.00
280	Harua	Shigeta Harua	2005-05-01	Nagano	Japan	173.00
281	Taki	Takayama Riki	2005-05-04	Kanagawa Prefecture	Japan	176.00
282	Maki	Riki Wilhelm Mauss	2006-02-17	Tokyo	Japan	184.00
283	E:U	Park Ji-won	1998-05-19	Gyeonggi-do	South Korea	161.00
284	Sihyeon	Kim Si-hyeon	1999-08-05	Gyeonggi-do	South Korea	170.00
285	Onda	Jo Se-lim	2000-05-18	Gyeonggi-do	South Korea	166.00
286	Aisha	Heo Yoo-rim	2000-07-21	Gyeonggi-do	South Korea	174.00
287	YooYeon	Kim Yoo-yeon	2001-02-09	Seoul	South Korea	165.00
288	Mayu	Kōma Mayu	2002-05-12	Gunma	Japan	157.00
289	Xinyu	Zhou Xinyu	2002-05-25	Beijing	China	174.00
290	NaKyoung	Kim Jun-seo	2002-10-13	Ulsan	South Korea	166.00
291	SoHyun	Park So-hyun	2002-10-13	Seoul	South Korea	167.00
292	DaHyun	Seo Da-hyun	2003-01-08	Busan	South Korea	160.00
293	Nien	Hsü Nien-tz'u	2003-06-02	New Taipei City	Taiwan	169.00
294	SeoYeon	Yoon Seo-yeon	2003-08-06	Daejeon	South Korea	161.00
295	JiYeon	Ji Suh-yeon	2004-02-13	Gyeonggi-do	South Korea	167.00
296	Kotone	Kamimoto Kotone	2004-03-10	Tokyo	Japan	162.00
297	ChaeYeon	Kim Chae-yeon	2004-12-04	Seoul	South Korea	171.00
298	YuBin	Gong Yu-bin	2005-02-03	Gyeonggi-do	South Korea	164.00
299	JiWoo	Lee Ji-woo	2005-10-24	Seoul	South Korea	173.00
300	Kaede	Yamada Kaede	2005-12-20	Toyama Prefecture	Japan	161.00
301	ShiOn	Park Shi-on	2006-04-03	Daejeon	South Korea	166.00
302	Lynn	Kawakami Lynn	2006-04-12	Tokyo	Japan	171.00
303	Sullin	Pirada Bunraksa	2006-11-30	Kanchanaburi	Thailand	169.00
304	HyeRin	Jeong Hye-rin	2007-04-12	Daegu	South Korea	162.00
305	ChaeWon	Kim Chae-won	2007-05-02	Incheon	South Korea	163.00
306	HaYeon	Jeong Ha-yeon	2007-08-01	Gyeonggi-do	South Korea	166.00
307	SooMin	Kim Soo-min	2007-10-03	Daegu	South Korea	161.00
308	YeonJi	Kwak Yeon-ji	2008-01-08	Seoul	South Korea	163.00
309	JooBin	Joo-bin	2009-01-16	Seoul	South Korea	168.00
310	SeoAh	Jeong Hae-rin	2010-06-11	Gwangju	South Korea	158.00
311	Leeteuk	Park Jung Soo	1983-07-01	Sinsa-dong	South Korea	174.00
312	Heechul	Kim Hee Сhul	1983-07-10	Gangwon-do	South Korea	178.00
313	Yesung	Kim Kang Hoon	1984-08-24	Seoul	South Korea	177.00
314	Shindong	Shin Dong Hee	1985-09-28	Mungyeong	South Korea	178.00
315	Sungmin	Lee Sung Min	1986-01-01	Gyeonggi	South Korea	175.00
316	Eunhyuk	Lee Hyuk Jae	1986-04-04	Incheon	South Korea	175.00
317	Siwon	Choi Si-won	1986-04-07	Seoul	South Korea	183.00
318	Donghae	Lee Dong Hae	1986-10-15	Sanjeong-dong	South Korea	172.00
319	Ryeowook	Kim Ryeo-wook	1987-06-21	Sangok-dong	South Korea	171.00
320	Kyuhyun	Cho Kyu Hyun	1988-02-03	Hagye-dong	South Korea	178.00
321	Chisa	Kondou Chisa	2002-01-17	Osaka	Japan	157.00
322	Hinata	Sohara Hinata	2002-06-11	Nagoya	Japan	157.00
323	Jurin	Asaya Jurin	2002-06-19	Kanagawa	Japan	158.00
324	Harvey	Amy Jannet Harvey	2002-12-18	Tokyo	Japan	169.00
325	Juria	Ueda Juria	2004-11-28	Osaka	Japan	164.00
326	Maya	Kawachi Maya	2005-08-10	Kantou	Japan	163.00
327	Cocona	Akiyama Cocona	2005-12-06	Kanto	Japan	159.00
\.


--
-- Data for Name: labels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.labels (id_label, name, founded_year, founder) FROM stdin;
1	HYBE Labels	\N	Bang Si Hyuk
2	JYP Entertainment Japan	\N	JYP Entertainment
3	YG Entertainment	1996	Yang Hyun-suk
4	Belift Lab	2018	Bang Si-hyuk
5	SM Entertainment	1989	Lee Soo Man
6	Warner Music Korea	\N	\N
7	KQ Entertainment	\N	Kim Kyu Wook
8	Warner Music Japan	\N	Warner Music Group
9	Source Music	\N	So Sung Jin
10	Starship Entertainment	\N	Kim Shi-dae
11	88rising	\N	Sean Miyashiro
12	Swing Entertainment	2018	\N
13	INB100	\N	Baekhyun
14	Dreamcatcher Company	\N	Lee Joo-Won
15	FNC Entertainment	\N	Han Seong Ho
16	BlockBerryCreative	\N	\N
17	RBW	\N	Kim Jin Woo
18	Fantagio	\N	Na Byeong-jun
19	MORE VISION	\N	Jay Park
20	143 Entertainment	\N	Park Jun Sang
21	WM Entertainment	\N	Lee Won Min
22	WAKEONE	2014	Son Dong-hoon
23	CHXXTA Company	2023	\N
24	XGALX	\N	\N
25	The Black Label	2015	Teddy Park
\.


--
-- Data for Name: tracks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tracks (id_album, title, genre) FROM stdin;
1	NORMAL (Explicit Ver.)	\N
1	NORMAL (Clean Ver.)	\N
1	NORMAL (Korean Ver.) (Explicit Ver.)	\N
1	NORMAL (Korean Ver.) (Clean Ver.)	\N
1	NORMAL (Instrumental)	\N
2	Come Over	\N
3	SWIM	\N
3	SWIM (Spring Waves Remix)	\N
3	SWIM (Instrumental)	\N
4	SWIM	\N
4	SWIM (Underwater Remix)	\N
4	SWIM (Inst.)	\N
5	SWIM	\N
5	SWIM with RM (Chill Hip Hop Remix)(feat.RM)	\N
5	SWIM with Jin (Alternative Rock Remix)(feat.Jin)	\N
5	SWIM with SUGA (Melodic Techno Remix)(feat.Suga)	\N
5	SWIM with j-hope (Afrobeat Remix)(feat.J-hope)	\N
5	SWIM with Jimin (Slow Jam R&B Remix)(feat.Jimin)	\N
5	SWIM with V (Electronic Remix)(feat.V)	\N
5	SWIM with Jung Kook (Acoustic Lofi Remix)(feat.Jungkook)	\N
5	SWIM (Inst.)	\N
6	Swim	\N
6	Swim (Instrumental)	\N
7	Body to Body	\N
7	Hooligan	\N
7	Aliens	\N
7	FYA	\N
7	2.0	\N
7	No. 29	\N
7	SWIM	\N
7	Merry Go Round	\N
7	NORMAL	\N
7	Like Animals	\N
7	they don't know 'bout us	\N
7	One More Night	\N
7	Please	\N
7	Into the Sun	\N
8	ON - Live	\N
8	불타오르네 (FIRE) - Live	\N
8	쩔어 - Live	\N
8	DNA - Live	\N
8	Blue & Grey - Live	\N
8	Black Swan - Live	\N
8	피 땀 눈물 - Live	\N
8	FAKE LOVE - Live	\N
8	Life Goes On - Live	\N
8	작은 것들을 위한 시 (Boy With Luv) (Feat. Halsey) - Live	\N
8	Dynamite - Live	\N
8	Butter - Live	\N
8	잠시 - Live	\N
8	Outro : Wings - Live	\N
8	Stay - Live	\N
8	So What - Live	\N
8	IDOL - Live	\N
8	Airplane pt.2 - Live	\N
8	뱁새 - Live	\N
8	병 - Live	\N
8	봄날 - Live	\N
8	Permission to Dance - Live	\N
9	BTS (방탄소년단) 'Take Two' Live Clip #2023BTSFESTA	\N
10	【THE PLANET Dance M/V】BTS - THE PLANET (Dance Cover By Bastions)	\N
11	RUN IT	\N
12	RUN IT	\N
13	STAY	\N
14	Endless Sun	\N
15	Stray Kids "Do It (Overdrive Version)" M/V	\N
15	Do It (Turbo Version)	\N
15	Do It (Sped Up)	\N
15	Do It (Slowed Down)	\N
15	Do It (Instrumental)	\N
15	Stray Kids "Do It" M/V	\N
16	DJ Snake - In The Dark (with Stray Kids) (Official Visualizer)	\N
17	Do It	\N
17	Divine	\N
17	Holiday	\N
17	Photobook	\N
17	Do It (Festival Ver.)	\N
18	CEREMONY	\N
18	CEREMONY (Hip Hip Version - English Version)	\N
18	CEREMONY (Hooray Version - English Version)	\N
18	CEREMONY (English Version)	\N
18	CEREMONY (Festival Version - English Version)	\N
19	CEREMONY	\N
19	CEREMONY (KARMA Version)	\N
19	CEREMONY (Sped Up Version)	\N
19	CEREMONY (Slowed Down Version)	\N
19	CEREMONY (Instrumental)	\N
20	BLEEP	\N
20	CEREMONY	\N
20	CREED	\N
20	MESS	\N
20	In My Head	\N
20	Half Time	\N
20	Phoenix	\N
20	Ghost	\N
20	0801	\N
20	Ceremony (Festival Ver.)	\N
20	Ceremony (English Ver.)	\N
21	JUMP (뛰어)	\N
21	GO	\N
21	Me and my	\N
21	Champion	\N
21	Fxxxboy	\N
22	JUMP (뛰어)	\N
23	THE GIRLS	\N
24	Pink Venom	\N
24	Shut Down	\N
24	Typa Girl	\N
24	Yeah Yeah Yeah	\N
24	Hard to Love	\N
24	The Happiest Girl	\N
24	Tally	\N
24	Ready For Love	\N
25	Pink Venom	\N
26	Ready For Love	\N
27	How You Like That - JP Ver.	\N
27	Ice Cream (with Selena Gomez)	\N
27	Pretty Savage - JP Ver.	\N
27	Bet You Wanna (feat. Cardi B)	\N
27	Lovesick Girls - JP Ver.	\N
27	Crazy Over You	\N
27	Love To Hate Me	\N
27	You Never Know - JP Ver.	\N
28	Kill This Love	\N
28	Crazy Over You	\N
28	How You Like That	\N
28	Don't Know What To Do	\N
28	불장난 (Playing With Fire)	\N
28	Lovesick Girls	\N
28	Love To Hate Me + You Never Know	\N
28	SOLO	\N
28	Gone	\N
28	Pretty Savage	\N
28	뚜두뚜두 (DDU-DU DDU-DU)	\N
28	휘파람 (Whistle)	\N
28	마지막처럼 (As If It's Your Last)	\N
28	Forever Young	\N
29	How You Like That	\N
29	Ice Cream (with Selena Gomez)	\N
29	Pretty Savage	\N
29	Bet You Wanna (feat. Cardi B)	\N
29	Lovesick Girls	\N
29	Crazy Over You	\N
29	Love To Hate Me	\N
29	You Never Know	\N
30	Ice Cream (with Selena Gomez)	\N
32	ME+YOU	\N
32	MEEEEEE (NAYEON)(feat.Nayeon)	\N
32	FIX A DRINK (JEONGYEON)(feat.Jeongyeon)	\N
32	MOVE LIKE THAT (MOMO)(feat.Momo)	\N
32	DECAFFEINATED (SANA)(feat.Sana)	\N
32	ATM (JIHYO)(feat.Jihyo)	\N
32	STONE COLD (MINA)(feat.Mina)	\N
32	CHESS (DAHYUN)(feat.Dahyun)	\N
32	IN MY ROOM (CHAEYOUNG)(feat.Chaeyoung)	\N
32	DIVE IN (TZUYU)(feat.Tzuyu)	\N
33	Up to you	\N
33	ENEMY	\N
33	FINE	\N
33	One day	\N
33	Blind in Love	\N
33	Love is more	\N
33	The wish	\N
33	Glow	\N
33	Like 1	\N
34	FOUR(feat.Nayeon,Jeongyeon,Jihyo,Mina)	\N
34	THIS IS FOR	\N
34	OPTIONS	\N
34	MARS	\N
34	RIGHT HAND GIRL	\N
34	PEACH GELATO	\N
34	HI HELLO	\N
34	BATTITUDE (NAYEON, JEONGYEON, MOMO, MINA)(feat.Nayeon,Jeongyeon,Momo,Mina)	\N
34	DAT AHH DAT OOH (SANA, JIHYO, DAHYUN, CHAEYOUNG, TZUYU)(feat.Sana,Jihyo,Dahyun,Chaeyoung,Tzuyu)	\N
34	LET LOVE GO (JEONGYEON, MOMO, SANA, TZUYU)(feat.Jeongyeon,Momo,Sana,Tzuyu)	\N
34	G.O.A.T. (MINA, DAHYUN, CHAEYOUNG)(feat.Mina,Dahyun,Chaeyoung)	\N
34	TALK (NAYEON, JIHYO)(feat.Nayeon,Jihyo)	\N
34	SEESAW	\N
34	HEARTBREAK AVENUE	\N
34	THIS IS FOR (Extended)	\N
34	TAKEDOWN (JEONGYEON, JIHYO, CHAEYOUNG)(feat.Jeongyeon,Jihyo,Chaeyoung)	\N
35	FOUR(feat.Nayeon,Jeongyeon,Jihyo,Mina)	\N
35	THIS IS FOR	\N
35	OPTIONS	\N
35	MARS	\N
35	RIGHT HAND GIRL	\N
35	PEACH GELATO	\N
35	HI HELLO	\N
35	BATTITUDE (NAYEON, JEONGYEON, MOMO, MINA)(feat.Nayeon,Jeongyeon,Momo,Mina)	\N
35	DAT AHH DAT OOH (SANA, JIHYO, DAHYUN, CHAEYOUNG, TZUYU)(feat.Sana,Jihyo,Dahyun,Chaeyoung,Tzuyu)	\N
35	LET LOVE GO (JEONGYEON, MOMO, SANA, TZUYU)(feat.Jeongyeon,Momo,Sana,Tzuyu)	\N
35	G.O.A.T. (MINA, DAHYUN, CHAEYOUNG)(feat.Mina,Dahyun,Chaeyoung)	\N
35	TALK (NAYEON, JIHYO)(feat.Nayeon,Jihyo)	\N
35	SEESAW	\N
35	HEARTBREAK AVENUE	\N
36	Talk that Talk (Japanese Ver.)	\N
36	SET ME FREE (Japanese Ver.)	\N
36	ONE SPARK (Japanese Ver.)	\N
36	Talk that Talk	\N
36	SET ME FREE	\N
36	I GOT YOU	\N
36	ONE SPARK	\N
36	Strategy	\N
37	Strategy (version 1.0)	\N
37	Strategy (Slom Remix)	\N
37	Strategy (House)	\N
37	Strategy (Moombahton)	\N
37	Strategy (Instrumental)	\N
38	The wish	\N
39	Strategy (feat. Megan Thee Stallion)	\N
39	Kiss My Troubles Away	\N
39	Like It Like It	\N
39	Sweetest Obsession	\N
39	Keeper	\N
39	Magical	\N
39	Strategy	\N
40	Beyond the Horizon	\N
40	DIVE	\N
40	Ocean Deep	\N
40	LOVE WARNING	\N
40	Here I am	\N
40	Inside of me	\N
40	Peach Soda	\N
40	Echoes of heart	\N
40	Dance Again	\N
40	Hare Hare	\N
42	We'll Be Fine	\N
43	The Beginning	\N
43	No Way Back(feat.So!Yoon!)	\N
43	The Fugitives	\N
43	Knife	\N
43	Stealer	\N
43	The Voice	\N
43	Witnesses	\N
43	Big Girls Don't Cry	\N
43	Lost Island	\N
43	Sleep Tight	\N
43	The Beyond	\N
44	One In A Billion (Japanese Ver.)	\N
44	CRIMINAL LOVE	\N
44	Fatal Trouble	\N
45	Shine On Me	\N
45	Echoes	\N
45	Bad Desire (With or Without You) (Japanese Ver.)	\N
46	Shine On Me	\N
47	Demons	\N
47	Demons (Instrumental)	\N
48	Flashover	\N
48	Bad Desire (With or Without You)	\N
48	Outside	\N
48	Loose (Korean Ver.)	\N
48	Helium	\N
48	Too Close	\N
48	Bad Desire (With or Without You) (English Ver.)	\N
48	Loose	\N
49	Loose	\N
50	No Doubt (Japanese Ver. / Digital Only)	\N
50	XO (Only If You Say Yes) (Japanese Ver. / Digital Only)	\N
51	Crown	\N
51	Back It Up	\N
51	Crazy	\N
51	Suffocate	\N
51	Moonlight Shadows	\N
51	Back Pocket	\N
51	Touch & Go	\N
51	Flatline	\N
51	I'm Home	\N
52	Thank You	\N
52	Miracle(feat.NCT WISH)	\N
52	Hug(feat.RIIZE)	\N
52	Rum Pum Pum Pum (첫 사랑니)(feat.aespa)	\N
52	Run Devil Run(feat.Red Velvet)	\N
52	Git It Up! (투지 (鬪志))(feat.EXO)	\N
52	Love Me Right(feat.NCT Dream)	\N
52	Juliette (줄리엣)(feat.WayV)	\N
52	You in Vague Memory (흐린 기억 속의 그대)(feat.NCT 127)	\N
52	My Everything (열정)(feat.Girls' Generation)	\N
52	I Pray 4 U(feat.SUPER JUNIOR)	\N
52	Psycho(feat.TVXQ!)	\N
52	Just A Feeling(feat.Kangta)	\N
52	Game(feat.naevis)	\N
52	View(feat.SHINee)	\N
52	My Name	\N
52	End of a Day (하루의 끝)(feat.BoA)	\N
53	Cream Soda	\N
53	Regret It	\N
53	Hear Me Out	\N
53	Private Party	\N
53	Cinderella	\N
53	No Makeup	\N
53	Love Fool	\N
53	Another Day	\N
53	Let Me In	\N
54	Hear Me Out	\N
55	Let Me In	\N
56	Welcome To SMCU PALACE	\N
56	The Cure(feat.Kangta,BoA,U-Know,Leeteuk,Taeyeon,Onew,Suho,Irene,Taeyong,Mark,Kun,Karina)	\N
56	Hot & Cold (온도차)(feat.Kai,Seulgi,Jeno,Karina)	\N
56	Beautiful Christmas(feat.Red Velvet,aespa)	\N
56	Jet(feat.Eunhyuk,Hyoyeon,Taeyong,Jaemin,Sungchan,Winter,Giselle)	\N
56	Priority(feat.Max Changmin,Taeyeon,Winter)	\N
56	Time After Time (원)(feat.BoA,Wendy,Ningning)	\N
56	Where You Are (넌 어디에)(feat.Ryeowook,Onew,Doyoung,Chenle,Xiaojun)	\N
56	Happier(feat.Kangta,Yesung,Suho,Taeil,Renjun)	\N
56	Good To Be Alive(feat.Hyoyeon,Key,Chen,Johnny,Ningning,Ginjo,Raiden,IMLAY,Mar Vista)	\N
57	Dreams Come True (aespa)(feat.aespa)	\N
57	Zoo (Taeyong, Jeno, Hendery, Yangyang, and Giselle)(feat.Taeyong,Jeno,YangYang,Giselle)	\N
57	Melody (Girls' Generation - Oh!GG)(feat.Girls' Generation)	\N
57	Magical (TVXQ and Super Junior)(feat.TVXQ!,SUPER JUNIOR)	\N
57	Snow Dream 2021 (Yeri, Haechan, Chenle, Jisung, and Ningning)(feat.Yeri,Haechan,Chenle,Jisung,Ningning)	\N
57	Ordinary Day (Kyuhyun, Onew, and Taeil)(feat.Kyuhyun,Onew,Taeil)	\N
57	12월의 인사 (Goodbye) (Sung by Sunny, Jungwoo, and Renjun)(feat.Sunny,Jungwoo,Renjun)	\N
57	동방신기 (DINNER) (TVXQ!)(feat.TVXQ!)	\N
57	우리들의 맹세 (The Promise of H.O.T.) (Jazz Ver.)	\N
57	빛 (Hope from KWANGYA)	\N
58	Don't fight the feeling	\N
58	Paradise	\N
58	No matter	\N
58	Runaway	\N
58	Just as usual	\N
60	Obsession	\N
60	Trouble	\N
60	Jekyll	\N
60	Groove	\N
60	Ya Ya Ya	\N
60	Baby You Are	\N
60	Non Stop	\N
60	Day After Day	\N
60	Butterfly Effect	\N
60	Obsession (Chinese Ver.)	\N
61	Tiny Light	\N
62	Where love passed	\N
63	HBD	\N
63	THUNDER	\N
63	Skyfall (THE 8 Solo)	\N
63	Fortunate Change (JOSHUA Solo)	\N
63	99.9% (WONWOO Solo)	\N
63	Raindrops (SEUNGKWAN Solo)	\N
63	Damage (HOSHI Solo) (feat. Timbaland)	\N
63	Shake It Off (MINGYU Solo)	\N
63	Happy Virus (DK Solo)	\N
63	Destiny (WOOZI Solo)	\N
63	Shining Star (Vernon Solo)	\N
63	Gemini (JUN Solo)	\N
63	Trigger (DINO Solo)	\N
63	Coincidence (JEONGHAN Solo)	\N
63	Jungle (S.COUPS Solo)	\N
63	Bad Influence (Prod. by Pharrell Williams)	\N
64	Shohikigen	\N
64	Circles (Japanese ver.)	\N
64	MAESTRO (Japanese ver.)	\N
65	Love, Money, Fame (feat. DJ Khaled)	\N
65	Love, Money, Fame (Kenia OS Remix)	\N
66	Love, Money, Fame (feat. DJ Khaled)	\N
66	Love, Money, Fame (Timbaland Remix)	\N
67	Love, Money, Fame (feat. DJ Khaled)	\N
67	Love, Money, Fame (English Ver.)	\N
67	Love, Money, Fame (Sped Up Ver.)	\N
67	Love, Money, Fame (Hitchhiker Remix)	\N
67	Love, Money, Fame (TAK Remix)	\N
68	Eyes on you	\N
68	LOVE, MONEY, FAME (feat. DJ Khaled)	\N
68	1 TO 13	\N
68	Candy	\N
68	Rain	\N
68	Water	\N
69	MAESTRO	\N
69	MAESTRO (Orchestra Remix)	\N
69	MAESTRO (Inst.)	\N
70	MAESTRO	\N
70	LALALI	\N
70	Spell	\N
70	Cheers to Youth	\N
70	CALL CALL CALL! (Korean Ver.)	\N
70	Happy Ending (Korean Ver.)	\N
70	Fallin' Flower (Korean Ver.)	\N
70	24H (Korean Ver.)	\N
70	Not Alone (Korean Ver.)	\N
70	Power of Love (Korean Ver.)	\N
70	DREAM (Korean Ver.)	\N
70	Ima -Even if the world ends tomorrow- (Korean Ver.)	\N
70	Adore U	\N
70	MANSAE	\N
70	Pretty U	\N
70	VERY NICE	\N
70	BOOMBOOM	\N
70	Don't Wanna Cry	\N
70	CLAP	\N
70	THANKS	\N
70	Oh My!	\N
70	Home	\N
70	Fear	\N
70	Left & Right	\N
70	HOME;RUN	\N
70	Ready to love	\N
70	Rock with you	\N
70	HOT	\N
70	_WORLD	\N
70	'F*ck My Life	\N
70	Super	\N
70	God of Music	\N
70	Adore U (Inst.) (Digital Only)	\N
72	Cosmic	\N
72	Sunflower	\N
72	Last Drop	\N
72	Love Arcade	\N
72	Bubble	\N
72	Night Drive	\N
72	Sweet Dreams	\N
73	Cosmic	\N
73	Sunflower	\N
73	Last Drop	\N
73	Love Arcade	\N
73	Bubble	\N
73	Night Drive	\N
74	Chill Kill	\N
74	Knock Knock (Who's There?)	\N
74	Underwater	\N
74	Will I Ever See You Again?	\N
74	Nightmare	\N
74	Iced Coffee	\N
74	One Kiss	\N
74	Bulldozer	\N
74	Wings	\N
74	풍경화 Scenery	\N
75	Red Flavor (빨간 맛) (Mar Vista Remix)	\N
76	Beautiful Christmas	\N
77	Birthday	\N
77	BYE BYE	\N
77	On A Ride (롤러코스터)	\N
77	ZOOM	\N
77	Celebrate	\N
78	Marionette	\N
78	WILDSIDE	\N
78	SAPPY	\N
78	Jackpot	\N
78	#Cookie Jar	\N
78	Snap Snap	\N
78	Sayonara	\N
78	Aitai-tai	\N
78	Swimming Pool	\N
78	'Cause it's you	\N
78	Color of Love	\N
80	Bed of Thorns	\N
80	Stick With You	\N
80	Take Me To Nirvana (feat. Vinida Weng)	\N
80	So What	\N
80	21st Century Romance	\N
80	Dream of Mine	\N
81	SSS (Sending Secret Signals) (feat. HYDE)	\N
82	Intro : SPARK	\N
82	Can't Stop	\N
82	Beautiful Strangers (Japanese Ver.)	\N
82	Where Do You Go?	\N
82	Deja Vu (Japanese Ver.)	\N
82	We’ll Never Change	\N
82	SSS (Sending Secret Signals)	\N
82	きっとずっと (Kitto Zutto)	\N
82	Step by Step	\N
82	Rise	\N
82	Hoshi No Uta (Japanese Ver.)	\N
82	Outro : GLOW	\N
83	Upside Down Kiss	\N
83	Beautiful Strangers	\N
83	Ghost Girl	\N
83	Sunday Driver	\N
83	Dance With You	\N
83	Take My Half	\N
83	Bird of Night	\N
83	Song of the Stars	\N
84	Step by Step	\N
85	[언젠가는 슬기로울 전공의생활 OST Part 9] 투모로우바이투게더 - 그날이 오면 M/V	\N
85	When the Day Comes (Instrumental)	\N
86	Love Language	\N
87	Surfing in the Moonlight	\N
88	Heaven	\N
88	Over The Moon	\N
88	Danger	\N
88	Resist (Not Gonna Run Away)	\N
88	Forty One Winks	\N
88	Higher Than Heaven	\N
89	PYTHON	\N
89	Our Youth	\N
89	SMOOTH	\N
89	REMEMBER	\N
89	Darling	\N
89	TIDAL WAVE	\N
89	OUT THE DOOR	\N
89	her	\N
89	Yours Truly,	\N
90	TRUTH	\N
90	Drive Me To The Moon	\N
90	Two	\N
90	NANANA	\N
90	Don't Care About Me	\N
90	Don't Leave Me Alone	\N
91	ENCORE	\N
92	Breath	\N
92	Last Piece	\N
92	Born Ready	\N
92	Special	\N
92	Wave	\N
92	Waiting For You	\N
92	Thank You, Sorry	\N
92	1+1	\N
92	I Mean It	\N
92	We Are Young	\N
93	Breath	\N
94	Aura	\N
94	Crazy	\N
94	Not By The Moon	\N
94	Love You Better	\N
94	Trust My Love	\N
94	Poison	\N
95	Sing For U	\N
95	Love Loop	\N
95	Your Space	\N
95	Bibouroku	\N
95	Karma	\N
95	Drunk	\N
96	You Calling My Name	\N
96	Pray	\N
96	Now or Never (feat. Jonas Blue)	\N
96	Thursday	\N
96	Run Away	\N
96	Crash & Burn	\N
97	Love Loop	\N
97	Your Space	\N
97	Bibouroku	\N
97	Karma	\N
97	Drunk	\N
97	#Summervibes	\N
97	Remember Me	\N
97	Superman	\N
97	Love Loop - Instrumental	\N
98	1°	\N
98	Eclipse	\N
98	The End	\N
98	Time Out	\N
98	Believe	\N
98	Page	\N
100	BAD (Ofenbach Ver.)	\N
101	BAD (James Carter Ver.)	\N
102	BAD (Steve Aoki Ver)	\N
103	Bad (Speed Up Ver.)	\N
103	Bad (Speed Down Ver.)	\N
103	Bad (Ollounder Ver.)	\N
103	Bad (LEEZ Ver.)	\N
104	BAD	\N
104	MAMACITA	\N
104	TOXIN	\N
104	Fallin'	\N
104	Body	\N
105	Adrenaline (NO1 Ver.)	\N
105	Adrenaline (Speed Up Ver.)	\N
105	Adrenaline (Speed Down Ver.)	\N
106	Ghost	\N
106	Adrenaline	\N
106	NASA	\N
106	On The Road	\N
106	Choose	\N
107	[MV] ATEEZ(에이티즈) - Waiting For You | 마지막 썸머(Last Summer) OST part 6	\N
107	Waiting for You (Instrumental)	\N
108	[Special Clip] ATEEZ(에이티즈) ‘Choose’	\N
109	Attitude	\N
110	LEMONADE (2Spade Remix)	\N
110	LEMONADE	\N
111	LEMONADE (Marlon Hoffstadt Remix)	\N
111	LEMONADE (Marlon Hoffstadt Extended Mix)	\N
111	LEMONADE	\N
112	LEMONADE (Zedd Remix)	\N
112	LEMONADE	\N
113	WDA (Whole Different Animal)(feat.G-Dragon)	\N
113	LEMONADE	\N
113	SHAKIN'	\N
113	Can't Help Myself	\N
113	Camouflage	\N
113	Bite	\N
113	Switchblade (feat. Ty Dolla $ign)	\N
113	Roll	\N
113	My Plan	\N
113	'Til We Die	\N
113	LEMONADE (feat. Becky G)	\N
113	LEMONADE (Sped Up Version)	\N
113	LEMONADE (Slowed Down Version)	\N
113	LEMONADE (Instrumental)	\N
113	Voice Memo (KARINA Version)	\N
113	Voice Memo (GISELLE Version)	\N
113	Voice Memo (WINTER Version)	\N
113	Voice Memo (NINGNING Version)	\N
114	Flashing Lights - (with Crush)(feat.Crush)	\N
114	Caution - (with NMIXX)(feat.NMIXX)	\N
114	Aftertaste - (with DEAN)(feat.Dean)	\N
114	PITC (Party in the Corner) - (with Hongjoong & Jay Park)(feat.Hongjoong,Jay Park)	\N
114	Fire With Fire (LNGSHOT)(feat.LNGSHOT)	\N
114	Can't Get Enough	\N
114	Bet On U - (with Chungha)(feat.Chungha)	\N
114	International - (with SOYEON)(feat.Soyeon)	\N
114	What About Us	\N
114	Wanna Buy a Plant + Cost Me - (with JO1)(feat.JO1)	\N
114	Keychain - (with aespa)(feat.aespa)	\N
114	One More Dance - (JOSHUA & Corbyn Besson)	\N
114	Wildcard - (KEVIN WOO)(feat.Kevin)	\N
114	Just One Bite	\N
114	Too Bad (K-POPS! Ver.) - (with G-Dragon)(feat.G-Dragon)	\N
114	Love Is Everywhere	\N
114	The Last	\N
115	WDA (Whole Different Animal)(feat.G-Dragon)	\N
116	ATTITUDE	\N
117	Keychain	\N
118	BLUE - WINTER Solo(feat.Winter)	\N
118	Ketchup And Lemonade - NINGNING Solo(feat.Ningning)	\N
118	Tornado - GISELLE Solo(feat.Giselle)	\N
118	GOOD STUFF - KARINA Solo(feat.Karina)	\N
119	Motto (English Ver.)	\N
119	Motto (Band Ver.)	\N
119	Motto (Unplugged Ver.)	\N
119	Motto (Inst.)	\N
120	Motto	\N
120	Glitch	\N
120	You And I	\N
120	Pocket (Yeji)	\N
120	Asylum (Lia)	\N
120	Look (Ryujin)	\N
120	Undefined (Chaeryeong)	\N
120	Tangerine (Yuna)	\N
121	TUNNEL VISION (R.Tee Remix)	\N
121	TUNNEL VISION (IMLAY Remix)	\N
121	TUNNEL VISION (2Spade Remix)	\N
121	TUNNEL VISION (CIFIKA Remix)	\N
121	TUNNEL VISION (English Ver.)	\N
121	TUNNEL VISION (Inst.)	\N
122	Focus	\N
122	TUNNEL VISION	\N
122	DYT	\N
122	Flicker	\N
122	Nocturne	\N
122	8-BIT HEART	\N
123	ROCK & ROLL	\N
123	I. I. Know Me	\N
123	Out of season	\N
123	Trigger	\N
123	Wind Ride	\N
123	Algorhythm (Final Ver.)	\N
123	No Biggie (Final Ver.)	\N
123	GOLD -Japanese ver.-	\N
123	Imaginary Friend -Japanese ver.-	\N
123	Girls Will Be Girls -Japanese ver.-	\N
124	Girls Will Be Girls (English Ver.)	\N
124	Girls Will Be Girls (Tech House Remix)	\N
124	Girls Will Be Girls (EDM Remix)	\N
124	Girls Will Be Girls (Rock Remix)	\N
125	Girls Will Be Girls	\N
125	Kiss & Tell	\N
125	Locked N Loaded	\N
125	Promise	\N
125	Walk	\N
126	GOLD (English Ver.)	\N
126	Imaginary Friend (English Ver.)	\N
127	GOLD	\N
127	Imaginary Friend	\N
127	Bad Girls R Us	\N
127	Supernatural	\N
127	FIVE	\N
127	VAY(feat.Changbin)	\N
127	BORN TO BE (Final Ver.)	\N
127	UNTOUCHABLE (Final Ver.)	\N
127	Mr. Vampire (Final Ver.)	\N
127	Dynamite (Final Ver.)	\N
127	Escalator (Final Ver.)	\N
128	Algorhythm	\N
128	No Biggie	\N
128	Algorhythm (Instrumental)	\N
128	No Biggie (Instrumental)	\N
129	Licorice (LOOZBONE Remix)	\N
129	Armageddon (SixThema & Epik Remix)	\N
129	Walk (Arkins Remix)	\N
129	Fact Check (Ezra Hazard Remix)	\N
129	Supernova (Fahjah Remix)	\N
129	Lemonade (RayRay Remix)	\N
129	Whiplash (DJ Long Nhat Remix)	\N
129	Love On The Floor (Aurede Remix)	\N
129	Breakfast (ASHID & 9INE6IX Remix)	\N
130	Show! Show! Show! (duco Remix)	\N
130	Whiplash (monotostereo Remix)	\N
130	UP (KARINA Solo) (Coziest Remix)	\N
130	Flights, Not Feelings (Demicat Remix)	\N
130	Rover (IMLAY Remix)	\N
130	Make A Wish (Birthday Song) (yunji Remix)	\N
130	Siren (Noisyfloor Remix)	\N
130	INVU (Yetsuby Remix)	\N
130	Smoothie (Departs Remix)	\N
130	Fact Check (Spearman Remix)	\N
130	Gas (Demicat Remix)	\N
130	Boom Boom Bass (Arkins Remix)	\N
130	Spark (WINTER Solo) (2Spade Remix)	\N
131	Intro: Wall to Wall	\N
131	Walk	\N
131	No Clue	\N
131	Orange Seoul	\N
131	Pricey	\N
131	Time Capsule	\N
131	Can't Help Myself	\N
131	Rain Drop	\N
131	Gas	\N
131	Suddenly	\N
131	Meaning of Love	\N
133	Be There For Me	\N
133	Home Alone	\N
133	White Lie	\N
134	Fact Check	\N
134	Space	\N
134	Parade	\N
134	Angel Eyes	\N
134	Yacht	\N
134	Je Ne Sais Quoi	\N
134	Love is a beauty	\N
134	Misty	\N
134	Real Life	\N
135	Ay-Yo	\N
135	Faster	\N
135	2 Baddies	\N
135	Time Lapse	\N
135	DJ	\N
135	Crash Landing	\N
135	Designer	\N
135	Gold Dust	\N
135	Black Clouds	\N
135	Playback	\N
135	Skyscraper (摩天樓; 마천루)	\N
135	Tasty (貘)	\N
135	Vitamin	\N
135	LOL (Laugh-Out-Loud)	\N
135	1, 2, 7 (Time Stops)	\N
136	Faster	\N
136	2 Baddies	\N
136	Time Lapse	\N
136	Crash Landing	\N
136	Designer	\N
136	Gold Dust	\N
136	Black Clouds	\N
136	Playback	\N
136	Tasty	\N
136	Vitamin	\N
136	LOL (Laugh-Out-Loud)	\N
136	1, 2, 7 (Time Stops)	\N
137	ICONIC BY MISTAKE	\N
137	ICONIC BY MISTAKE (Clean Edit)	\N
137	ICONIC BY MISTAKE (Instrumental)	\N
138	BOOMPALA (feat. GURU RANDHAWA)	\N
138	BOOMPALA	\N
139	BOOMPALA (feat. SANTOS BRAVOS)	\N
139	BOOMPALA	\N
140	Boompala (Champions Remix)	\N
140	Boompala	\N
141	CELEBRATION (Supergirl Version)	\N
141	CELEBRATION	\N
142	BOOMPALA	\N
142	BOOMPALA (KIM CHAEWON Version)	\N
142	BOOMPALA (SAKURA Version)	\N
142	BOOMPALA (HUH YUNJIN Version)	\N
142	BOOMPALA (KAZUHA Version)	\N
142	BOOMPALA (HONG EUNCHAE Version)	\N
143	BOOMPALA	\N
143	BOOMPALA (Karaoke Ver.)	\N
143	BOOMPALA (Piano Ver.)	\N
143	BOOMPALA (Sped Up Ver.)	\N
143	BOOMPALA (Slowed + Reverb Ver.)	\N
143	BOOMPALA (Short Ver.)	\N
143	BOOMPALA (Inst.)	\N
144	Pureflow	\N
144	BOOMPALA	\N
144	CELEBRATION	\N
144	Creatures	\N
144	iffy iffy	\N
144	Need Your Company	\N
144	Sonder	\N
144	Saki (feat. Aliyah's Interlude)	\N
144	Irony	\N
144	Trust Exercise	\N
144	Liminal Space	\N
146	Celebration	\N
146	Celebration (Sped Up Ver.)	\N
146	Celebration (Slowed + Reverb Ver.)	\N
146	Celebration (Instrumental)	\N
146	Celebration (Karaoke Ver.)	\N
147	TNT	\N
147	REDRED	\N
147	ACAI	\N
147	YOUNGCREATORCREW	\N
147	Wassup	\N
147	Blue Lips	\N
148	REDRED	\N
149	Mention Me	\N
150	GO!	\N
150	What You Want	\N
150	FaSHioN	\N
150	JoyRide	\N
150	Lullaby	\N
150	What You Want (feat. Teezo Touchdown)	\N
151	CORTIS (코르티스) 'What You Want (feat. Teezo Touchdown)’ Official Visualizer	\N
152	What You Want	\N
153	Sugar Honey Ice Tea	\N
154	MOON	\N
154	CHOOM	\N
154	I LIKE IT	\N
154	LOCKED IN	\N
155	WE GO UP	\N
155	PSYCHO	\N
155	SUPA DUPA LUV	\N
155	WILD	\N
156	DRIP (Remix) (Live)	\N
156	BATTER UP (Live)	\N
156	CLIK CLAK (Live)	\N
156	LIKE THAT (Live)	\N
156	SHEESH (Live)	\N
156	Woke Up In Tokyo (RUKA & ASA) (Live)	\N
156	Love, Maybe (Live)	\N
156	DREAM (Live)	\N
156	BILLIONAIRE (Live)	\N
156	Really Like You (Live)	\N
156	CLAP YOUR HANDS ~ Go Away (2NE1 Cover) (Live)	\N
156	FOREVER (Live)	\N
156	Love In My Heart (Live)	\N
157	HOT SAUCE	\N
158	Ghost	\N
159	CLIK CLAK	\N
159	DRIP	\N
159	Love, Maybe	\N
159	Really Like You	\N
159	BILLIONAIRE	\N
159	Love In My Heart	\N
159	Woke Up In Tokyo (RUKA & ASA)	\N
159	FOREVER	\N
159	BATTER UP (Remix) - Bonus Track	\N
160	BATTER UP JP Ver.	\N
161	FOREVER	\N
162	MONSTERS (Intro)	\N
162	SHEESH	\N
162	LIKE THAT	\N
162	Stuck In The Middle (7 ver.)	\N
162	BATTER UP (7 ver.)	\N
162	DREAM	\N
162	Stuck In The Middle (Remix)	\N
163	Sunday Morning	\N
164	GRWM (Get Ready With Me)	\N
164	It's Me	\N
164	paw, paw!	\N
164	Mamihlapinatapai	\N
164	Love, older you	\N
165	Bubee (Korean Version)	\N
166	Bubee	\N
167	Sunday Morning	\N
168	NOT CUTE ANYMORE	\N
168	NOT CUTE ANYMORE (Holiday Party ver.)	\N
168	NOT CUTE ANYMORE (Holiday Night ver.)	\N
168	NOT CUTE ANYMORE (Sped Up ver.)	\N
168	NOT CUTE ANYMORE (Holiday Party Sped up ver.)	\N
168	NOT CUTE ANYMORE (Holiday Night Sped up ver.)	\N
168	NOT CUTE ANYMORE (Instrumental)	\N
169	ALL FOR YOU	\N
169	ALL FOR YOU (Instrumental)	\N
170	NOT CUTE ANYMORE	\N
170	NOT ME	\N
171	Love Smile	\N
171	Love Smile (Instrumental)	\N
172	Heal	\N
172	Growing Pains	\N
172	Baby Blue	\N
172	This!	\N
172	Before You Met Me	\N
172	Glass Half Empty	\N
172	Main Attraction	\N
172	Enemies with Benefits	\N
172	On Our Way	\N
172	Sorry To Myself	\N
173	growing pains	\N
174	Baby Blue	\N
175	N the Front (H.ONE Remix)	\N
176	Do What I Want	\N
176	N The Front	\N
176	Savior	\N
176	Tuscan Leather	\N
176	Catch Me Now	\N
176	Fire & Ice	\N
208	TKO	\N
177	MONSTA X 몬스타엑스 'Do What I Want' MV	\N
178	Beautiful Liar -Japanese ver.-	\N
178	GAMBLER -Japanese ver.-	\N
178	BEASTMODE -Japanese ver.-	\N
178	BEBE -Japanese ver.-	\N
179	Rush Hour (Rerecorded)	\N
179	Autobahn (Rerecorded)	\N
179	Ride with U (Rerecorded)	\N
179	Mercy (Rerecorded)	\N
179	LOVE (Rerecorded)	\N
179	사랑한다 (Rerecorded)	\N
179	Beautiful Liar (Rerecorded)	\N
179	LONE RANGER (Rerecorded)	\N
179	Deny (Rerecorded)	\N
179	괜찮아 (Rerecorded)	\N
180	SWING	\N
181	MONSTA X 몬스타엑스 'Beautiful Liar' MV	\N
181	Daydream	\N
181	춤사위 (Crescendo)	\N
181	LONE RANGER	\N
181	Deny	\N
181	[몬채널][S] MONSTA X 몬스타엑스 - 괜찮아 (Self-cam ver.)	\N
182	Mono (Feat. Skaiwater)	\N
182	Gimme Dat Love	\N
182	Morning	\N
182	Crow	\N
182	Love Is Pain	\N
183	Crow	\N
184	Hide and Seek	\N
185	Mono (Feat. skaiwater)	\N
186	GAME	\N
187	Where Do We Go	\N
187	Invincible	\N
187	Farewell to the World	\N
187	Fate (Japanese ver.)	\N
187	Queencard (Japanese ver.)	\N
188	[Solo Leveling:ARISE x i-dle] “ARISE”🎵 Music Video Short Film Version Revealed!	\N
188	ARISE (Instrumental)	\N
189	Girlfriend	\N
189	Good Thing	\N
189	Love Tease	\N
189	Chain	\N
189	Unstoppable	\N
189	If You Want	\N
190	LATATA (i-dle ver.)	\N
190	HANN (Alone) (i-dle ver.)	\N
190	Senorita (i-dle ver.)	\N
190	Uh-Oh (i-dle ver.)	\N
190	i’M THE TREND (i-dle ver.)	\N
190	Oh my god (i-dle ver.)	\N
190	LION (i-dle ver.)	\N
190	DUMDi DUMDi (i-dle ver.)	\N
190	HWAA (i-dle ver.)	\N
191	Klaxon	\N
191	Bloom	\N
191	Last Forever	\N
191	Neverland	\N
192	Atmos	\N
192	HOURS	\N
192	Possibility	\N
192	Anti Believer	\N
192	Still Raining	\N
192	Thousand Miles Away	\N
193	Poet | Artist	\N
193	Starlight	\N
194	HARD	\N
194	JUICE	\N
194	10X	\N
194	Satellite	\N
194	Identity	\N
194	The Feeling	\N
194	Like It	\N
194	Sweet Misery	\N
194	Insomnia	\N
194	Gravity	\N
195	SHINee シャイニー 'SUPERSTAR' MV	\N
195	Closer	\N
195	SHINee 샤이니 'Don't Call Me' MV	\N
195	SHINee 샤이니 'Atlantis' MV	\N
195	Seasons	\N
196	Atlantis	\N
196	CØDE	\N
196	Don't Call Me	\N
196	Area	\N
196	Heart Attack	\N
196	Marry You	\N
196	Days and Years	\N
196	I Really Want You	\N
196	Kiss Kiss	\N
196	Attention	\N
196	Body Rhythm	\N
196	Kind	\N
197	SHINee 샤이니 'Don't Call Me (Fox Stevenson Remix)' MV	\N
197	Don't Call Me (ESAI Remix)	\N
198	Don't Call Me	\N
198	Heart Attack	\N
198	Marry You	\N
198	CØDE	\N
198	I Really Want You	\N
198	Kiss Kiss	\N
198	Body Rhythm	\N
198	Attention	\N
198	Kind	\N
199	All Day All Night	\N
199	Countless	\N
199	Good Evening	\N
199	Chemistry	\N
199	Electric	\N
199	Who Waits For Love	\N
199	Our Page	\N
199	I Say	\N
199	Retro	\N
199	Drive	\N
199	I Want You	\N
199	Undercover	\N
199	JUMP	\N
199	Tonight	\N
199	You & I	\N
199	Lock You Down - Special Track	\N
200	LUCID DREAM (Taku Takahashi Remix)	\N
201	Lucid Dream	\N
201	Fashion	\N
201	Jigsaw	\N
201	Rebel Heart (Japanese Ver.)	\N
201	Attitude (Japanese Ver.)	\N
201	Thank U (Japanese ver.)	\N
202	Fashion	\N
203	BLACKHOLE	\N
203	BANG BANG	\N
203	Hush	\N
203	Stuck In Your Head	\N
203	Fireworks	\N
203	HOT COFFEE	\N
203	8 (JANG WONYOUNG Solo)	\N
203	Odd (GAEUL Solo)	\N
203	Super ICY (LEESEO Solo)	\N
203	Unreal (LIZ Solo)	\N
203	In Your Heart (REI Solo)	\N
203	Force (AN YUJIN Solo)	\N
204	BANG BANG	\N
205	XOXZ	\N
205	Wild Bird	\N
205	Dear, My Feelings	\N
205	GOTCHA (Baddest Eros)	\N
205	삐빅 (♥beats)	\N
205	Midnight Kiss	\N
206	Be Alright	\N
206	DARE ME	\N
206	Accendio -Japanese version-	\N
206	Blue Heart -Japanese version-	\N
206	WOW -Japanese version-	\N
207	DARE ME	\N
208	REBEL HEART	\N
208	FLU	\N
208	You Wanna Cry	\N
208	Thank U	\N
208	ATTITUDE	\N
209	REBEL HEART	\N
210	FOREVER 1 (Matisse & Sadko Remix)	\N
210	FOREVER 1 (Aiobahn Remix)	\N
210	FOREVER 1 (Mar Vista Remix)	\N
210	FOREVER 1 (Matisse & Sadko Remix, Extended Version)	\N
210	FOREVER 1 (Aiobahn Remix, Extended Version)	\N
210	FOREVER 1 (Mar Vista Remix, Extended Version)	\N
211	FOREVER 1	\N
211	You Better Run	\N
211	Villain	\N
211	Lucky Like That	\N
211	Closer	\N
211	Seventeen	\N
211	Paper Plane	\N
211	Freedom	\N
211	Mood Lamp	\N
211	Summer Night	\N
212	Girls Are Back	\N
212	All Night	\N
212	Holiday	\N
212	Fan	\N
212	Only One	\N
212	One Last Time	\N
212	Sweet Talk	\N
212	Love is Bitter	\N
212	It's You	\N
212	Light Up The Sky	\N
213	Sailing (0805)	\N
213	Sailing (0805) (Instrumental)	\N
214	Party	\N
214	Lion Heart	\N
214	You Think	\N
214	Check	\N
214	One Afternoon	\N
214	Show Girls	\N
214	Fire Alarm	\N
214	Talk Talk	\N
214	Green Light	\N
214	Paradise	\N
214	Sign	\N
214	Bump It	\N
215	PARTY	\N
215	Check	\N
215	PARTY (Instrumental)	\N
216	Catch Me If You Can (Korean Version)	\N
216	Girls (Korean Version)	\N
217	Mr. Mr.	\N
217	Goodbye	\N
217	Europa	\N
217	Wait a Minute	\N
217	Back Hug	\N
217	Soul	\N
218	Spring Breeze, Again	\N
219	WE WANNA GO	\N
220	Beautiful (Part.3)	\N
221	Light	\N
221	Kangaroo (Prod. ZICO)	\N
221	Forever And A Day (Prod. NELL)	\N
221	Sandglass (Prod. Heize)	\N
221	11 (Eleven) (Prod. Dynamicduo)	\N
222	GOLD	\N
222	I PROMISE YOU (I.P.U.)	\N
222	BOOMERANG	\N
222	WE ARE	\N
222	DAY BY DAY	\N
222	I'LL REMEMBER	\N
222	I PROMISE YOU (Propose Ver.)	\N
223	Nothing Without You (Intro.)	\N
223	Beautiful	\N
223	Wanna	\N
223	Twilight	\N
223	Burn it Up (Prequel Remix)	\N
223	Energetic (Prequel Remix)	\N
223	Wanna Be (My Baby)	\N
223	Energetic	\N
223	Burn It Up	\N
223	To be One (Outro)	\N
224	To be one (Intro)	\N
224	Burn it Up	\N
224	Energetic	\N
224	Wanna Be (My Baby)	\N
224	Always (Acoustic Ver.)	\N
225	Supernatural	\N
225	Right Now	\N
225	Supernatural (Instrumental)	\N
225	Right Now (Instrumental)	\N
226	How Sweet	\N
226	Bubble Gum	\N
226	How Sweet (Instrumental)	\N
226	Bubble Gum (Instrumental)	\N
227	Ditto – 250 Remix	\N
227	OMG – FRNK Remix	\N
227	Attention – 250 Remix	\N
227	Hype Boy – 250 Remix	\N
227	Cookie – FRNK Remix	\N
227	NewJeans (뉴진스) 'Hurt (250 Remix)' Special Video	\N
227	Ditto – 250 Remix (Instrumental)	\N
227	OMG – FRNK Remix (Instrumental)	\N
227	Attention – 250 Remix (Instrumental)	\N
227	Hype Boy – 250 Remix (Instrumental)	\N
227	Cookie – FRNK Remix (Instrumental)	\N
227	Hurt – 250 Remix (Instrumental)	\N
228	Our Night is more beautiful than your Day	\N
228	Our Night is more beautiful than your Day (Inst.)	\N
229	GODS	\N
230	Beautiful Restriction	\N
231	New Jeans	\N
231	Super Shy	\N
231	ETA	\N
231	Cool With You	\N
231	Get Up	\N
231	ASAP	\N
232	New Jeans	\N
232	Super Shy	\N
233	Zero (J.I.D Remix)	\N
234	Be Who You Are (Real Magic) (feat. JID, NewJeans & Camilo)	\N
235	Baggy Jeans	\N
235	Call D	\N
235	PADO	\N
235	Interlude: Oasis	\N
235	The BAT	\N
235	Alley Oop	\N
235	That’s Not Fair	\N
235	Kangaroo	\N
235	Not Your Fault	\N
235	Golden Age	\N
236	New Axis	\N
236	Universe (Let's Play Ball)	\N
236	Earthquake	\N
236	OK!	\N
236	Birthday Party	\N
236	Know Now	\N
236	Dreaming	\N
236	Round&Round	\N
236	Miracle	\N
236	Vroom	\N
236	Sweet Dream	\N
236	Good Night	\N
236	Beautiful	\N
237	Make a Wish (Birthday Song) [Wuki Remix]	\N
237	90's Love (SQUAR Remix)	\N
238	Resonance	\N
239	90's Love	\N
239	Misfit (NCT U)	\N
239	Raise The Roof	\N
239	Volcano	\N
239	Light Bulb	\N
239	Dancing In The Rain	\N
239	My Everything	\N
239	Interlude: Past To Present	\N
239	Make A Wish (Birthday Song)	\N
239	Déjà Vu	\N
239	Nectar	\N
239	Music, Dance	\N
239	Faded In My Last Song	\N
239	From Home	\N
239	From Home (Korean Ver.)	\N
239	Make a Wish (Birthday Song) (English Ver.)	\N
239	Interlude: Present to Future	\N
239	Work It	\N
239	All About You	\N
239	I.O.U.	\N
239	Outro: Dream Routine	\N
240	Make a Wish (Birthday Song)	\N
240	Misfit	\N
240	Volcano	\N
240	Light Bulb	\N
240	Dancing in the Rain	\N
240	Interlude: Past to Present	\N
240	Déjà Vu	\N
240	Nectar	\N
240	Music, Dance	\N
240	Faded In My Last Song	\N
240	From Home	\N
240	From Home (Korean Ver.)	\N
240	Make a Wish (Birthday Song) (English Ver.)	\N
241	Timeless	\N
241	INTRO: Neo Got My Back	\N
241	BOSS	\N
241	Baby Don't Stop	\N
241	GO	\N
241	TOUCH	\N
241	YESTODAY	\N
241	Black on Black	\N
241	The 7th Sense	\N
241	Without You	\N
241	Without You (Chinese Ver.)	\N
241	Dream in a Dream (Ten Solo)	\N
241	OUTRO: VISION	\N
241	YESTODAY - Extended Version	\N
242	Pinky Up	\N
243	Pinky Up	\N
243	Pinky Up (Club Remix)	\N
243	Pinky Up (Sunset Remix)	\N
243	Pinky Up (Katwalk Remix)	\N
243	Pinky Up (Techno Remix)	\N
244	PINKY UP	\N
245	Internet Girl	\N
246	M.I.A (VALORANT Game Changers Version)	\N
247	Gnarly - (Extended Version)	\N
247	Gabriela - (JULiA LEWiS Reggaeton Remix)	\N
247	Gabriela - (Extended Version)	\N
247	Gabriela - (Sped Up Version)	\N
247	Gameboy - (JULiA LEWiS Acoustic Remix)	\N
247	Gameboy - (Extended Version)	\N
247	Gameboy - (Sped Up Version)	\N
248	Gabriela (Young Miko Remix)	\N
249	Monster High Fright Song ft. KATSEYE	\N
249	Monster High Fright Song ft. KATSEYE (Animated M/V)	\N
250	Time Lapse	\N
250	Time Lapse (Instrumental)	\N
251	Be My Love	\N
251	Be My Love (Inst.)	\N
252	Paper Cuts	\N
253	CBX	\N
253	Ka-CHING!	\N
253	Horololo	\N
253	Girl Problems	\N
253	Shake	\N
253	Off The Wall	\N
253	Ringa Ringa Ring	\N
253	Gentleman	\N
253	Watch Out	\N
253	Cry	\N
253	In This World	\N
254	Beautiful World	\N
255	Monday Blues	\N
255	Blooming Day	\N
255	Sweet Dreams	\N
255	Thursday	\N
255	Vroom Vroom	\N
255	Playdate	\N
255	Lazy	\N
256	Someone Like You	\N
256	Someone Like You (Inst.)	\N
257	Cry	\N
258	It's Running Time!	\N
259	Girl Problems	\N
259	Ka-CHING!	\N
259	Hey Mama!	\N
259	Tornado Spiral	\N
259	Miss You	\N
259	Diamond Crystal	\N
259	KING and QUEEN	\N
260	CRUSH U (with Yoonsang)	\N
261	Beat It Up	\N
261	Rush	\N
261	Cold Coffee	\N
261	Butterflies	\N
261	Tempo	\N
261	TRICKY	\N
262	BTTF	\N
262	CHILLER	\N
262	I LIKE IT	\N
262	DREAM TEAM	\N
262	Interlude : Back to Our Paradise	\N
262	’Bout You	\N
262	That Summer	\N
262	Miss Me	\N
262	Beautiful Sailing	\N
263	INTRO : DREAMSCAPE	\N
263	When I’m With You	\N
263	Flying Kiss	\N
263	i hate fruits	\N
263	No Escape	\N
263	Best of Me	\N
263	YOU	\N
263	Heavenly	\N
263	Night Poem	\N
263	Off The Wall	\N
263	Rains in Heaven	\N
264	Hello Future - KENZIE RE:WORKS	\N
265	Rains in Heaven	\N
266	Moonlight	\N
266	Stupid Cupid	\N
267	Smoothie	\N
267	icantfeelanything	\N
267	BOX	\N
267	Carat Cake	\N
267	UNKNOWN	\N
267	Breathing	\N
268	NCT DREAM, JVKE 'Broken Melodies (JVKE Remix)' (Official Audio)	\N
268	NCT DREAM 엔시티 드림 'Broken Melodies' MV	\N
269	Crescendo	\N
269	Heavy Serenade	\N
269	IDESERVEIT	\N
269	Different Girl	\N
269	Superior	\N
269	LOUD	\N
270	TIC TIC (feat. Pabllo Vittar)	\N
271	[제4차 사랑혁명] 엔믹스(NMIXX) 배이 - Up&Down MV ㅣOSTㅣ웨이브 오리지널	\N
271	Up & Down (Inst.)	\N
272	MEXE (feat. Cobrah & NMIXX)	\N
272	Mexe (feat. NMIXX) (Miss Tacacá & LOFIHOUSEBOY Remix)	\N
272	MEXE	\N
273	NMIXX(엔믹스) “Blue Valentine” M/V	\N
273	Blue Valentine (English Ver.)	\N
273	Blue Valentine (A Cappella Ver.)	\N
273	Blue Valentine (Sped Up Ver.)	\N
273	Blue Valentine (Inst.)	\N
274	Blue Valentine	\N
274	SPINNIN’ ON IT	\N
274	Phoenix	\N
274	Reality Hurts	\N
274	RICO	\N
274	Game Face	\N
274	PODIUM	\N
274	Crush On You	\N
274	ADORE U	\N
274	Shape of Love	\N
274	O.O Part 1 (Baila)	\N
274	O.O Part 2 (Superhero)	\N
275	MEXE	\N
276	릴리 (NMIXX) & 지우 (NMIXX) & 규진 (NMIXX) - Ridin′ (Prod. THE HUB)｜ WSWF｜Lyric Video｜Stone Music Playlist	\N
277	KNOW ABOUT ME	\N
277	Slingshot	\N
277	Golden Recipe	\N
277	Papillon	\N
277	Ocean	\N
277	NMIXX(엔믹스) “High Horse” (Official Audio)	\N
279	Lemon Tang	\N
279	15-LOVE	\N
279	Baby Steps	\N
279	heart emoji (♡)	\N
279	Secret Recipe	\N
279	RUDE!	\N
280	RUDE! (Silly Silky Remix)(feat.Silly Silky)	\N
280	RUDE! (yunji Remix)	\N
280	RUDE!	\N
281	Rude! (Japanese Ver.)	\N
282	RUDE!	\N
283	The Chase (0to Remix)	\N
283	The Chase (YOHAN Remix)	\N
283	The Chase (SONGUN Remix)	\N
283	The Chase (Arti & Suchan Kim Remix)	\N
283	The Chase (SOR Remix)	\N
284	FOCUS (Jaebin Remix)	\N
284	FOCUS (DJ Seinfeld Remix)	\N
284	FOCUS (Young Franco Remix)	\N
284	FOCUS (sooyeon Remix)	\N
284	Hearts2Hearts 하츠투하츠 'FOCUS' MV	\N
285	FOCUS	\N
285	Apple Pie	\N
285	Pretty Please	\N
285	Flutter	\N
285	Blue Moon	\N
286	Pretty Please	\N
287	STYLE	\N
288	My Christmas Sweet Love	\N
288	Jazz Bar (Carol ver.)	\N
288	Wonderland (Carol ver.)	\N
289	Intro : 7' Dreamcatcher	\N
289	JUSTICE	\N
289	STΦMP!	\N
289	2 Rings	\N
289	Fireflies	\N
290	Lullaby (2024 Concert Ver.)	\N
290	The curse of the Spider (2024 Concert Ver.)	\N
291	Intro : This My Fashion	\N
291	OOTD	\N
291	Rising	\N
291	Shatter	\N
291	We Are Young	\N
292	Dreamcatcher(드림캐쳐) 'BONVOYAGE (Farewell Ver.)' MV (Lyrics)	\N
293	Intro : From us	\N
293	BONVOYAGE	\N
293	DEMIAN	\N
293	Propose	\N
293	To. You	\N
294	REASON	\N
294	REASON (Inst.)	\N
295	Intro : Chaotical X	\N
295	VISION	\N
295	Fairytale	\N
295	Some Love	\N
295	Rainy Day	\N
295	Outro : Mother Nature	\N
296	Intro : Save us	\N
296	Locked Inside A Door	\N
296	MAISON	\N
296	Starlight	\N
296	Together	\N
296	Always	\N
296	Skit : The seven doors	\N
296	Cherry (Real Miracle) (JI U SOLO)	\N
296	No Dot (SU A SOLO)	\N
296	Entrancing (SIYEON SOLO)	\N
296	Winter (HANDONG SOLO)	\N
296	For (YOOHYEON SOLO)	\N
296	Beauty Full (DAMI SOLO)	\N
296	Playground (GAHYEON SOLO)	\N
297	Intro	\N
297	BEcause	\N
297	Airplane	\N
297	Whistle	\N
297	Alldaylong	\N
297	A Heart of Sunflower	\N
299	UNIQUE	\N
299	Pandemonium	\N
299	L.O.Y.L.	\N
299	Wednesday Girl	\N
299	Triple 7	\N
299	ICE (VVS)	\N
300	EX	\N
300	Dancing Queen	\N
300	Stupid Brain	\N
300	Night Of My Life	\N
300	EX (Spanish ver.)	\N
301	DUH!	\N
301	Pretty Boy	\N
301	Murmur	\N
301	Flashy	\N
301	Work	\N
301	Over And Over	\N
302	R.O.P (Reign of Peace) (Prod. Czaer)	\N
302	R.O.P (Reign of Peace) (Instrumental) (Prod. Czaer)	\N
303	SAD SONG	\N
303	It's Alright	\N
303	Last Call	\N
303	Welcome To	\N
303	All You	\N
303	WASP	\N
303	SAD SONG (English Ver.)	\N
304	Killin' It (English Version) (때깔 (Killin' It) (English Version))	\N
305	Killin' It	\N
305	Late Night Calls	\N
305	Everybody Clap	\N
305	Love Story	\N
305	Countdown To Love	\N
305	Emergency	\N
305	2Nite	\N
305	Let Me Love You	\N
305	Street Star	\N
305	I See U	\N
306	Fall In Love Again (Prod. by C. “Tricky” Stewart & Believve)	\N
307	JUMP (English Version)	\N
308	NCT U 엔시티 유 'Do It (Let’s Play)' NCT ZONE OST Making Video	\N
309	Marine Turtle	\N
309	Marine Turtle (Korean Ver.)	\N
309	Marine Turtle (Instrumental)	\N
310	N.Y.C.T	\N
310	N.Y.C.T (Inst.)	\N
311	Rain Day	\N
311	Rain Day (Inst.)	\N
312	coNEXTion (Age of Light)	\N
313	Universe (Let's Play Ball)	\N
314	[MV] NCT U _ Maniac (Sung by DOYOUNG(도영),HAECHAN(해찬)) (Prod. RYAN JHUN(라이언전))	\N
315	Coming Home	\N
315	Coming Home (Inst.)	\N
316	LUMINOUS	\N
316	SICK LOVE	\N
316	Hi High (Japanese Version)	\N
317	The Journey	\N
317	Flip That	\N
317	Need U	\N
317	POSE	\N
317	Pale Blue Dot	\N
317	Playback	\N
318	JINAON (Epilogue)(feat.Hyolyn,Yuna,Seola,Eunha,HeeJin,Yeseo)	\N
319	Waka Boom (My Way)(feat.Hyolyn,Lee Young-ji)	\N
319	AURA(feat.WJSN)	\N
319	THE GIRLS (Can't turn me down)(feat.Kep1er)	\N
319	Red Sun!(feat.VIVIZ)	\N
319	POSE(feat.LOONA)	\N
319	Whistle(feat.BB GIRLS)	\N
320	Butterfly(feat.LOONA)	\N
320	Red Sun (Remix)(feat.BB GIRLS)	\N
320	See Sea, BAE(feat.Hyolyn)	\N
321	Purr(feat.SinB,Umji,Xiaoting,Dayeon,Hikaru)	\N
321	KA-BOOM!(feat.Hyolyn,Eunseo,Yeoreum)	\N
321	Tell me now(feat.Eunji,Yves,HeeJin,Choerry,HyeJu)	\N
322	Don't Go (Queendom2 Ver.)(feat.JinSoul,HaSeul,Kim Lip,Chuu,Chaehyun,Youngeun)	\N
323	NAVILLERA(feat.WJSN)	\N
323	SHAKE IT(feat.LOONA)	\N
323	MVSK (Remix)(feat.BB GIRLS)	\N
324	WA DA DA (QUEENDOM2 Ver.)(feat.Kep1er)	\N
324	Chi Mat Ba Ram+Rollin' (Remix)(feat.BB GIRLS)	\N
324	As You Wish(feat.WJSN)	\N
324	PTT (Paint The Town)(feat.LOONA)	\N
325	Yummy-Yummy	\N
325	Yummy-Yummy - Instrumental	\N
326	Blooming (Intro)	\N
326	4 Flowers	\N
326	4 Flowers (Acoustic Remix)	\N
326	4 Flowers (Latin Remix)	\N
326	4 Flowers (Inst.)	\N
327	MMM Simile (Live ver.)	\N
327	MMM Simile (Inst.)	\N
328	ILLELLA	\N
328	L.I.E.C (L.I.E.C)	\N
328	1,2,3 Eoi!	\N
329	Where Are We Now -Japanese ver.-	\N
329	Another Day (내일의 너, 오늘의 나 (Another Day))	\N
329	A Memory for Life (애써 (A Memory for Life))	\N
329	Destiny Part.2 (우린 결국 다시 만날 운명이었지 Part.2 (Destiny Part.2))	\N
329	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
329	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
329	MAMAMOO「mumumumuch -Japanese ver.-」 Music Video	\N
329	Strange Day	\N
330	Paint Me (Orchestra ver.) (칠해줘 (Paint Me) (Orchestra ver.))	\N
330	Starry Night (Orchestra ver.) (별이 빛나는 밤 (Starry Night) (Orchestra ver.))	\N
330	gogobebe (Rock ver.) (고고베베 (gogobebe) (Rock ver.))	\N
330	Egotistic (Blistering sun ver.) (너나 해 (Egotistic) (Blistering sun ver.))	\N
330	You’re the best 2021 (넌 is 뭔들 2021 (You’re the best 2021))	\N
330	I Miss You 2021 (I Miss You 2021)	\N
330	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
330	HeeHeeHaHeHo Part.2 (히히하헤호 Part.2 (HeeHeeHaHeHo Part.2))	\N
330	Words Don't Come Easy 2021 (우리끼리 2021 (Words Don't Come Easy 2021))	\N
330	Piano Man 2021 (Piano Man 2021)	\N
330	AHH OOP 2021 (AHH OOP 2021)	\N
330	Decalcomanie 2021 (Decalcomanie 2021)	\N
330	AYA (Traditional ver.) (AYA (Traditional ver.))	\N
330	HIP (Remix ver.) (HIP (Remix ver.))	\N
330	A little bit 2021 (따끔 2021 (A little bit 2021))	\N
330	Wind flower (Dramatic ver.) (Wind flower (Dramatic ver.))	\N
330	Um Oh Ah Yeh 2021 (음오아예 2021 (Um Oh Ah Yeh 2021))	\N
330	Don’t Be Happy 2021 (행복하지마 2021 (Don’t Be Happy 2021))	\N
330	Peppermint Chocolate (MMM ver.) (썸남썸녀 (Peppermint Chocolate) (MMM ver.))	\N
330	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
330	Destiny (Extended ver.) (우린 결국 다시 만날 운명이었지 (Destiny) (Extended ver.))	\N
330	Mr. Ambiguous 2021 (Mr.애매모호 2021 (Mr. Ambiguous 2021))	\N
330	Yes I am (Funk boost ver.) (나로 말할 것 같으면 (Yes I am) (Funk boost ver.))	\N
331	Where Are We Now	\N
331	Another Day	\N
331	A Memory for Life	\N
331	Destiny Part.2	\N
332	MAMAMOO - WANNA BE MYSELF	\N
332	[MV] 마마무 (MAMAMOO) - 딩가딩가 (Dingga)	\N
332	MAMAMOO - AYA	\N
332	MAMAMOO - Travel	\N
332	MAMAMOO - Chuck	\N
332	MAMAMOO - Diamond	\N
332	MAMAMOO - Good Night	\N
332	MAMAMOO - AYA (Japanese Ver.)	\N
332	MAMAMOO - Dingga (Japanese Ver.)	\N
332	MAMAMOO - Just Believe in Love	\N
333	Travel	\N
333	Dingga	\N
333	AYA	\N
333	Chuck	\N
333	Diamond	\N
333	Good Night	\N
334	Dingga	\N
334	Dingga (Inst.)	\N
335	WANNA BE MYSELF	\N
335	WANNA BE MYSELF (Inst.)	\N
336	Season of Memories	\N
336	Always	\N
337	GFRIEND (여자친구) '우리의 다정한 계절 속에' OFFICIAL MV	\N
338	MAGO	\N
338	Love Spell	\N
338	Three Of Cups	\N
338	GRWM	\N
338	Secret Diary	\N
338	Better Me	\N
338	Night Drive	\N
338	GFRIEND - Apple	\N
338	GFRIEND - Crossroads	\N
338	GFRIEND - Labyrinth	\N
338	GFRIEND - Wheel of the year	\N
339	Apple	\N
339	Eye of The Storm	\N
339	Room of Mirrors	\N
339	Tarot Cards	\N
339	Crème Brulée	\N
339	Stairs In The North	\N
340	Labyrinth	\N
340	GFRIEND (여자친구) '교차로 (Crossroads)' Official M/V	\N
340	Here We Are	\N
340	지금 만나러 갑니다 (Eclipse)	\N
340	Dreamcatcher	\N
340	From Me	\N
341	Apple	\N
341	Eye of The Storm	\N
341	Room of Mirrors	\N
341	Tarot Cards	\N
341	Crème Brûlée	\N
341	Stairs in the North	\N
342	Labyrinth	\N
342	Crossroads	\N
342	Here We Are	\N
342	Eclipse	\N
342	Dreamcatcher	\N
342	From Me	\N
343	Fallin' Light	\N
343	Memoria	\N
343	FLOWER	\N
343	SUNRISE -JP ver.-	\N
344	Fever	\N
344	Mr. Blue	\N
344	Smile	\N
344	Wish	\N
344	Paradise	\N
344	Hope	\N
344	FLOWER - Korean Version	\N
344	Fever - Instrumental	\N
345	GFRIEND - Cheers (ZZAN)	\N
346	Memory of the Moon	\N
347	Twilight	\N
348	Circles	\N
349	U&Iverse	\N
350	Candy Sugar Pop	\N
350	Something Something	\N
350	More	\N
350	Light the sky	\N
350	Story	\N
350	All Day	\N
350	First Love	\N
350	Let's go ride	\N
350	S#1.	\N
350	24 Hours	\N
350	Like stars	\N
351	Ichiban Suki na Hito ni Sayonara wo Iou	\N
351	Ichiban Suki na Hito ni Sayonara wo Iou (Inst.)	\N
352	ALIVE	\N
353	All Good-JP Ver.-	\N
354	After Midnight	\N
354	Footprint	\N
354	Waterfall	\N
354	Sunset Sky	\N
354	MY ZONE	\N
354	Don’t Worry	\N
355	Dear my universe	\N
355	Butterfly Effect	\N
355	ONE	\N
355	Someone Else	\N
355	SNS	\N
355	All Good	\N
355	All Stars	\N
355	Our spring	\N
355	Stardust	\N
355	gemini	\N
356	Still Life	\N
357	Flower Road	\N
358	FXXK IT	\N
358	LAST DANCE	\N
358	GIRL FRIEND	\N
358	LET'S NOT FALL IN LOVE	\N
358	LOSER	\N
358	BAE BAE	\N
358	BANG BANG BANG	\N
358	SOBER	\N
358	IF YOU	\N
358	ZUTTER (GD&T.O.P)	\N
358	WE LIKE 2 PARTY	\N
360	ZUTTER (GD&T.O.P)	\N
360	LET'S NOT FALL IN LOVE	\N
361	If you	\N
361	SOBER	\N
362	BANG BANG BANG	\N
362	We like 2 party	\N
363	LOSER	\N
363	BAE BAE	\N
364	Still Alive	\N
364	MONSTER	\N
364	Feeling	\N
364	FANTASTIC BABY	\N
364	BAD BOY	\N
364	BLUE	\N
364	Bingle Bingle	\N
364	Ego	\N
364	Love Dust	\N
364	Monster (Inst.)	\N
365	Intro (Alive)	\N
365	BLUE	\N
365	Love Dust	\N
365	BAD BOY	\N
365	Ain't No Fun	\N
365	FANTASTIC BABY	\N
365	Wings (Daesung Solo)	\N
366	06070	\N
366	VIRAL	\N
366	ddok ddok ddok	\N
366	ADIOS!	\N
366	Upside Down	\N
366	DIVE	\N
366	Forever You	\N
366	I Wonder	\N
367	KNOCK KNOCK KNOCK	\N
368	No Doubt	\N
368	No Doubt (Inst.)	\N
369	Earth, Wind & Fire (Buldak Hotter Than My EX Ver.)	\N
370	Nice Guy (Live Ver.)	\N
370	Serenade (Live Ver.)	\N
370	123-78 (Live Ver.)	\N
370	OUR (Live Ver.)	\N
370	l i f e i s c o o l (Live Ver.)	\N
370	But I Like You (Live Ver.)	\N
370	One and Only (Live Ver.)	\N
370	Step By Step (Live Ver.)	\N
370	IF I SAY, I LOVE YOU (Live Ver.)	\N
370	I Feel Good (Live Ver.)	\N
370	Dangerous (Live Ver.)	\N
370	But Sometimes (Live Ver.)	\N
370	Crying (Live Ver.)	\N
370	Dear. My Darling (Live Ver.)	\N
370	Gonna Be A Rock (Live Ver.)	\N
370	Earth, Wind & Fire (Live Ver.)	\N
371	SAY CHEESE!	\N
372	Live In Paris	\N
372	Hollywood Action	\N
372	JAM!	\N
372	Bathroom	\N
372	As Time Goes By	\N
373	Count To Love	\N
373	I Feel Good (Japanese Version)	\N
373	Nice Guy (Japanese Version)	\N
373	Dangerous (Japanese Version)	\N
374	123-78	\N
374	I Feel Good	\N
374	Step By Step	\N
374	Is That True?	\N
374	Next Mistake	\N
374	IF I SAY, I LOVE YOU	\N
374	I Feel Good (English Ver.)	\N
375	Never Loved This Way Before	\N
375	Never Loved This Way Before (Instrumental)	\N
376	4SHO 4SHO	\N
376	YEAH YEAH!	\N
376	NO HI, NO HEY	\N
376	RUN IT UP	\N
376	GGUKBONG	\N
376	MOYA	\N
376	THE PURGE 4SHOMIX	\N
376	PUBLIC ENEMY 4SHOMIX(feat.DJ Wegun)	\N
377	Good Girls (Louis Solo)	\N
377	Boo Thang (Woojin Solo)	\N
377	Summer Eyes (Ohyul Solo)	\N
377	For Us (Ryul Solo)	\N
377	Vanilla Days	\N
378	Are You Ready	\N
378	Trust Myself	\N
378	Thinking	\N
378	All Good	\N
378	Ejeh	\N
378	Next 2 U	\N
378	My Side	\N
378	Next 2 U (Sped Up)	\N
378	Next 2 U (Carol Remix)	\N
378	Next 2 U (Carol Remix) (Sped Up)	\N
379	Saucin’	\N
379	Moonwalkin	\N
379	FaceTime	\N
379	Backseat	\N
379	Never Let Go	\N
380	Saucin’	\N
381	iKON - "PANORAMA" MV	\N
381	T.T.M	\N
382	U	\N
382	Tantara	\N
382	RUM PUM PUM	\N
382	Like a Movie	\N
382	Driving Slowly	\N
382	Never Forget You	\N
382	All The Way Here	\N
382	FIGHTING - SONG SOLO	\N
382	Kiss Me - DK SOLO	\N
382	Want You Back - JU-NE SOLO	\N
383	BUT YOU	\N
383	DRAGON	\N
383	FOR REAL?	\N
383	GOLD	\N
383	NAME	\N
384	At ease	\N
385	Why Why Why	\N
386	Ah Yeah	\N
386	Dive	\N
386	All The World	\N
386	Holding On	\N
386	Flower	\N
387	I'm OK	\N
388	GOODBYE ROAD	\N
388	Don't Let Me Know	\N
388	ADORE YOU	\N
388	PERFECT	\N
389	KILLING ME	\N
389	Freedom	\N
389	Only You	\N
389	Cocktail	\N
389	Just For You	\N
390	Rubber Band	\N
391	THE RULES	\N
391	SERVE	\N
391	Extancy (Wumuti & Rui)	\N
391	BACK 2 BACK	\N
391	HIPS (Hyun & Haru)	\N
391	Masterpiece	\N
391	SERVE (Inst.)	\N
392	Rizz	\N
392	Scent	\N
392	Dirty Baby	\N
392	Biii:-P	\N
392	Kiss and say goodbye	\N
392	Drip Drip	\N
393	1&Only	\N
393	1 of LOV	\N
393	BIZNESS	\N
393	1 & Only (Instrumental)	\N
393	1 of LOV (Instrumental)	\N
393	BIZNESS (Instrumental)	\N
394	I’mma Be	\N
394	I'mma Be (88 Techno Remix by dxp)	\N
394	I'mma Be (Dark House Remix by dxp)	\N
394	I'mma Be (Backing Track)	\N
396	Intro.	\N
396	TOP 5	\N
396	V For Vision	\N
396	Customize	\N
396	Exotic	\N
396	Changes	\N
396	Zero To Hundred	\N
397	Running to Future	\N
397	ROSES	\N
397	LOVEPOCALYPSE	\N
398	ROSES	\N
399	Running to Future	\N
400	ICONIK (Japanese ver.)	\N
400	SLAM DUNK (Japanese ver.)	\N
400	BLUE (Japanese ver.)	\N
401	ICONIK	\N
401	SLAM DUNK	\N
401	Lovesick Game	\N
401	Goosebumps	\N
401	Dumb	\N
401	NOW OR NEVER (Korean ver.)	\N
401	EXTRA(feat.Sung Han Bin,Seok Matthew,Kim Gyu Vin,Park Gun Wook,Han Yu Jin)	\N
401	Long Way Back(feat.Kim Ji Woong,Zhang Hao,Kim Tae Rae,Ricky)	\N
401	Star Eyes	\N
401	I Know U Know	\N
402	D-DAY (ZEROBASEONE)	\N
402	UPSIDE DOWN (YOUNG POSSE)	\N
402	Goodbye (Choo Young-woo)	\N
402	Better with you (Colde)	\N
402	When we meet again (Miyeon)	\N
402	Close to You  (CHEEZE)	\N
402	Burden (Jo Hyun-ah)	\N
402	D-DAY (Instrumental)	\N
402	UPSIDE DOWN (Instrumental)	\N
402	Goodbye (Instrumental)	\N
402	Better with you (Instrumental)	\N
402	When we meet again (Instrumental)	\N
402	Close To You (Instrumental)	\N
402	Burden (Instrumental)	\N
403	SLAM DUNK	\N
404	D-DAY	\N
404	D-DAY (Inst.)	\N
405	ZERO:ATTITUDE	\N
406	D-D-DANCE	\N
407	Mis-en-Scène	\N
407	Panorama	\N
407	Island	\N
407	Sequence	\N
407	O Sole Mio	\N
407	느린여행 Slow Journey	\N
408	Beware	\N
408	Vampire	\N
408	好きと言わせたい Suki to Iwasetai	\N
408	Waiting	\N
408	Buenos Aires	\N
408	好きになっちゃうだろう? Suki ni Nacchaudarou? (IZ*ONE Version)	\N
408	Yummy Summer(feat.Sakura,Kim Chaewon,Minju,Yujin)	\N
408	La Vie en Rose (Japanese Version)	\N
408	Violeta (Japanese Version)	\N
408	FIESTA (Japanese Version)	\N
408	夢を見ている間 Yume wo Miteiru Aida (Japanese Version)	\N
408	どうすればいい? Dousurebaii?(feat.Kwon Eunbi,Yena,Hitomi,Wonyoung)	\N
408	Shy Boy(feat.Kang Hyewon,Lee Chae Yeon,Nako,Jo Yuri)	\N
409	Welcome	\N
409	환상동화 Secret Story of the Swan	\N
409	Pretty	\N
409	회전목마 Merry-Go-Round	\N
409	Rococo	\N
409	With*One	\N
409	Secret Story of the Swan - Japanese Ver.	\N
409	Merry-Go-Round - Japanese Ver.	\N
410	EYES	\N
410	FIESTA	\N
410	DREAMLIKE(feat.Kwon Eunbi,Sakura,Kang Hyewon,Yena,Hitomi,Wonyoung)	\N
410	AYAYAYA(feat.Kwon Eunbi,Sakura,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Jo Yuri,Yujin)	\N
410	SO CURIOUS(feat.Yena,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Hitomi,Jo Yuri,Yujin,Wonyoung)	\N
410	SPACESHIP	\N
410	우연이 아니야 DESTINY	\N
410	YOU & I	\N
410	DAYDREAM(feat.Kwon Eunbi,Lee Chae Yeon,Minju,Yujin)	\N
410	PINK BLUSHER(feat.Sakura,Kang Hyewon,Nako,Hitomi,Wonyoung)	\N
410	언젠가 우리의 밤도 지나가겠죠 SOMEDAY(feat.Yena,Kim Chaewon,Jo Yuri)	\N
410	OPEN YOUR EYES	\N
411	Vampire	\N
411	君以外 (Kimi Igai)	\N
411	Love Bubble(feat.Kwon Eunbi,Sakura,Kang Hyewon,Hitomi,Kim Chaewon,Jo Yuri)	\N
411	紫外線なんかぶっとばせ (Shigaisennanka Buttobase)(feat.Yena,Wonyoung,Lee Chae Yeon,Nako,Yujin,Minju)	\N
411	不機嫌Lucy (Fukigen Lucy)(feat.Yena,Lee Chae Yeon)	\N
412	Buenos Aires	\N
412	Tomorrow	\N
412	Target(feat.Kwon Eunbi,Yujin,Lee Chae Yeon,Sakura,Minju,Kang Hyewon)	\N
412	年下Boyfriend (Toshishita Boyfriend)(feat.Yena,Jo Yuri,Kim Chaewon,Wonyoung,Nako,Hitomi)	\N
412	Human Love(feat.Jo Yuri,Yujin)	\N
413	해바라기 Hey. Bae. Like it.	\N
413	비올레타 Violeta	\N
413	Highlight	\N
413	Really Like You	\N
413	Airplane	\N
413	하늘 위로 Up	\N
413	고양이가 되고 싶어 NEKONI NARITAI (Korean Ver.)	\N
413	기분 좋은 안녕 GOKIGEN SAYONARA (Korean Ver.)	\N
414	好きと言わせたい (Suki to Iwasetai)	\N
414	ケンチャナヨ (Gwaen Chanha Yo)	\N
414	ご機嫌サヨナラ (Gokigen Sayonara)(feat.Wonyoung,Yujin,Kwon Eunbi,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Hitomi)	\N
414	猫になりたい (Neko ni Naritai)(feat.Sakura,Yena,Jo Yuri,Nako,Minju)	\N
414	ダンスを思い出すまで (Dance o Omoidasumade)(feat.Wonyoung,Sakura)	\N
416	We on Fire	\N
416	Bewitched	\N
416	HOTLINE	\N
416	Sakura-iro Yell	\N
416	We on Fire (Korean Ver.)	\N
416	Bewitched (Korean Ver.)	\N
417	Back to Life	\N
417	Lunatic	\N
417	MISMATCH	\N
417	Rush	\N
417	Heartbreak Time Machine	\N
417	Who am I	\N
418	Go in Blind	\N
418	Run Wild	\N
418	Wolf type	\N
418	Extraordinary day	\N
418	Go in Blind (Korean ver.)	\N
418	Run Wild (Korean ver.)	\N
419	Extraordinary day	\N
420	Magic Hour	\N
420	&TEAM 'Wonderful World' Focus Cam (방과후 ver.)	\N
421	Yukiakari	\N
421	Deer Hunter	\N
421	Illumination	\N
421	Crescent moon’s wish	\N
421	Samidare	\N
421	Scar to Scar	\N
421	Maybe	\N
421	Aoarashi	\N
421	Koegawari	\N
421	Imprinted	\N
421	Jyuugoya	\N
421	Big Suki	\N
421	Beat the Odds	\N
421	MEME	\N
421	Samidare (Korean ver.)	\N
421	Scar to Scar (Korean ver.)	\N
421	Aoarashi (Korean ver.)	\N
421	Koegawari (Korean ver.)	\N
421	Yukiakari (Korean ver.)	\N
421	Deer Hunter (Korean ver.)	\N
421	Dropkick (Korean ver.)	\N
421	Feel the Pulse	\N
422	Jyuugoya	\N
422	Big suki	\N
423	Feel the Pulse	\N
424	Beat the odds	\N
425	BREAKOUT	\N
425	FOCUS	\N
425	CODE	\N
425	Can't Be Broken	\N
426	Zombie	\N
426	Colourz	\N
426	Back 2 Luv	\N
427	SLAY	\N
427	Oh Ma Ma God	\N
427	Make Me Feel	\N
429	TheFatRat & EVERGLOW - Ghost Light	\N
429	Ghost Light (Korean)	\N
429	Ghost Light (Sped Up)	\N
429	Ghost Light (Instrumental)	\N
429	Ghost Light (Slowed Down Reverb)	\N
430	EVERGLOW - Pirate (R3HAB Remix) (Official Visualizer)	\N
431	Back Together	\N
431	Pirate	\N
431	Don’t Speak	\N
431	Nighty Night	\N
431	Company	\N
432	PROMISE (for UNICEF PROMISE CAMPAIGN)	\N
433	FIRST	\N
433	DON′T ASK DON′T TELL	\N
433	PLEASE PLEASE	\N
434	Let Me Dance	\N
434	Let Me Dance (Instrumental)	\N
435	Baby Flower (Seoul Remix : Vendors)	\N
435	Baby Flower (Bangkok Remix : Kurtz)	\N
435	Baby Flower (Taipei Remix : ntrophy)	\N
435	Baby Flower (Tokyo Remix : Full8loom)	\N
436	Baby Flower -Japanese Ver.- - Baby Flower Japanese Version	\N
437	Sad Girls Schemin'	\N
437	Peer	\N
437	Baby Flower	\N
437	Type of Girl	\N
437	Sleek	\N
437	I Like That	\N
437	Me Myself Mode	\N
438	Tokimetique	\N
438	Tokimetique -Shin Sakiura Remix-	\N
438	Tokimetique TV Edit	\N
439	Are You Alive (깨어) (Inst.)	\N
439	Detective Soseol (추리소설) (Inst.)	\N
439	Firework Diary (어제 우리 불꽃놀이) (Inst.)	\N
439	Love Child (Inst.)	\N
439	Persona (Inst.)	\N
439	Too Hot (Inst.)	\N
439	Diablo (Inst.)	\N
439	Friend Zone (Inst.)	\N
439	Love2Love (Inst.)	\N
439	Fly Up (Inst.)	\N
439	Cameo Love (Inst.)	\N
439	Bubble Gum Girl (Inst.)	\N
439	Q&A (Inst.)	\N
439	Christmas Alone (Inst.)	\N
440	Magic Shine New Zone	\N
440	Fly Up(feat.neptune)	\N
440	Cameo Love(feat.moon)	\N
440	Bubble Gum Girl(feat.sun)	\N
440	Q&A(feat.zenith)	\N
440	Christmas Alone	\N
441	Password	\N
441	ヘッドフォン - Headphones	\N
441	トキメティック - Tokimetique	\N
441	TOKYO	\N
441	Oshare	\N
441	アンタイトル - Untitled	\N
441	### (∞! Ver.)	\N
442	Password	\N
443	Pink Power	\N
443	Pink Power (inst.)	\N
444	@% (Alpha Percent)	\N
444	깨어 (Are You Alive)	\N
444	추리소설 (Detective Soseol)	\N
444	어제 우리 불꽃놀이 (Firework Diary)	\N
444	Love Child	\N
444	Persona	\N
444	Too Hot	\N
444	Diablo	\N
444	Friend Zone	\N
444	Love2Love	\N
445	SUPER JUNIOR 슈퍼주니어 'Express Mode' MV	\N
445	Haircut	\N
445	Air	\N
445	Delight	\N
445	I Know	\N
445	Say Less	\N
445	D.N.A.	\N
445	Finale	\N
445	우리의 꽃말 Stuck With You	\N
446	Show Time	\N
447	Celebrate	\N
447	Hate Christmas	\N
447	Snowman	\N
447	White Love	\N
447	If only you (Special Track)	\N
448	Mango	\N
448	Don't Wait	\N
448	My Wish	\N
448	Everyday	\N
448	Always	\N
449	Callin' (Winter for Spring ver.)	\N
449	Analogue Radio	\N
449	Callin' (Inst.)	\N
449	Analogue Radio (Inst.)	\N
450	SUPER	\N
450	House Party	\N
450	Burn The Floor	\N
450	Paradox	\N
450	Closer	\N
450	The Melody	\N
450	Raining Spell for Love (Remake Version)	\N
450	Mystery	\N
450	More Days with You	\N
450	Tell Me Baby	\N
451	MAMACITA -AYAYA- -Japanese Version-	\N
451	Black Suit - Japanese Ver.	\N
451	Devil - Japanese Ver.	\N
451	I Think I	\N
451	One More Time (Otra Vez) (feat. REIK) - Japanese Ver.	\N
451	On and On	\N
451	Blue World	\N
451	Magic - Japanese Ver.	\N
451	Wow! Wow!! Wow!!!	\N
451	Star	\N
451	MOTORCYCLE	\N
451	Saturday Night	\N
451	JOIN HANDS	\N
451	Let's Get It On	\N
451	Celebration～君に架ける橋～	\N
451	雨のち晴れの空の色	\N
451	僕のまじめなラブコメディー	\N
451	Splash	\N
451	Sunrise	\N
451	Because I Love You ～大切な絆～	\N
451	桜の花が咲く頃	\N
451	Coming Home	\N
452	XIGNAL (The Intro)	\N
452	GALA	\N
452	ROCK THE BOAT	\N
452	TAKE MY BREATH	\N
452	NO GOOD	\N
452	HYPNOTIZE	\N
452	UP NOW	\N
452	O.R.B (Obviously Reads Bro)	\N
452	4 SEASONS	\N
452	PS118	\N
453	XG - GALA (Official Music Video)	\N
453	GALA (Instrumental)	\N
454	X-GENE (HESONOO) (XG 1st WORLD TOUR “The first HOWL” Live)	\N
454	HOWLING & GRL GVNG [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	UNDEFEATED [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	TGIF & IYKYK [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	Tippy Toes & SOMETHING AIN’T RIGHT & IN THE RAIN [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	SHOOTING STAR [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	WOKE UP [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	PUPPET SHOW [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	XG - IS THIS LOVE (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
454	XG - NEW DANCE (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
454	XG - MILLION PLACES (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
454	WINTER WITHOUT YOU & MASCARA [XG 1st WORLD TOUR “The first HOWL” Live]	\N
454	LEFT RIGHT [XG 1st WORLD TOUR “The first HOWL” Live]	\N
455	XG - MILLION PLACES (Official Music Video)	\N
455	LEFT RIGHT (Y2K Ver.)	\N
455	PUPPET SHOW (City Pop Ver.) (XG “The first HOWL” Live)	\N
455	MILLION PLACES (Instrumental)	\N
456	XG - IN THE RAIN (Official Music Video)	\N
456	IN THE RAIN x XDM	\N
456	IN THE RAIN (Instrumental)	\N
457	XG - IS THIS LOVE (Official Music Video)	\N
457	IS THIS LOVE (Piano Ver.)	\N
457	IS THIS LOVE (Instrumental)	\N
457	IS THIS LOVE (Piano Ver.) (Instrumental)	\N
458	HESONOO + X-GENE x XDM	\N
458	GRL GVNG x XDM	\N
458	WOKE UP x XDM	\N
458	SOMETHING AIN’T RIGHT x XDM	\N
458	TGIF x XDM	\N
458	PUPPET SHOW x XDM	\N
458	TIPPY TOES x XDM	\N
458	NEW DANCE x XDM	\N
459	WINTER WITHOUT YOU -Orchestra ver.-	\N
459	WINTER WITHOUT YOU -Orchestra ver.- (Instrumental)	\N
460	HOWL	\N
460	HOWLING	\N
460	SPACE MEETING Skit	\N
460	IYKYK	\N
460	SOMETHING AIN'T RIGHT	\N
460	IN THE RAIN	\N
460	WOKE UP REMIXX [PROD BY JAKOPS] (FEAT. Jay Park, OZworld, AKLO, Paloalto, VERBAL, Awich, Tak, Dok2)	\N
460	IS THIS LOVE	\N
461	IYKYK	\N
225	How Sweet	\N
225	Bubble Gum	\N
225	How Sweet (Instrumental)	\N
225	Bubble Gum (Instrumental)	\N
226	Ditto – 250 Remix	\N
226	OMG – FRNK Remix	\N
226	Attention – 250 Remix	\N
226	Hype Boy – 250 Remix	\N
226	Cookie – FRNK Remix	\N
226	NewJeans (뉴진스) 'Hurt (250 Remix)' Special Video	\N
226	Ditto – 250 Remix (Instrumental)	\N
226	OMG – FRNK Remix (Instrumental)	\N
226	Attention – 250 Remix (Instrumental)	\N
226	Hype Boy – 250 Remix (Instrumental)	\N
226	Cookie – FRNK Remix (Instrumental)	\N
226	Hurt – 250 Remix (Instrumental)	\N
227	Our Night is more beautiful than your Day	\N
227	Our Night is more beautiful than your Day (Inst.)	\N
228	GODS	\N
229	Beautiful Restriction	\N
230	New Jeans	\N
230	Super Shy	\N
230	ETA	\N
230	Cool With You	\N
230	Get Up	\N
230	ASAP	\N
232	Zero (J.I.D Remix)	\N
233	Be Who You Are (Real Magic) (feat. JID, NewJeans & Camilo)	\N
234	Baggy Jeans	\N
234	Call D	\N
234	PADO	\N
234	Interlude: Oasis	\N
234	The BAT	\N
234	Alley Oop	\N
234	That’s Not Fair	\N
234	Kangaroo	\N
234	Not Your Fault	\N
234	Golden Age	\N
235	New Axis	\N
235	Universe (Let's Play Ball)	\N
235	Earthquake	\N
235	OK!	\N
235	Birthday Party	\N
235	Know Now	\N
235	Dreaming	\N
235	Round&Round	\N
235	Miracle	\N
235	Vroom	\N
235	Sweet Dream	\N
235	Good Night	\N
235	Beautiful	\N
236	Make a Wish (Birthday Song) [Wuki Remix]	\N
236	90's Love (SQUAR Remix)	\N
237	Resonance	\N
238	90's Love	\N
238	Misfit (NCT U)	\N
238	Raise The Roof	\N
238	Volcano	\N
238	Light Bulb	\N
238	Dancing In The Rain	\N
238	My Everything	\N
238	Interlude: Past To Present	\N
238	Make A Wish (Birthday Song)	\N
238	Déjà Vu	\N
238	Nectar	\N
238	Music, Dance	\N
238	Faded In My Last Song	\N
238	From Home	\N
238	From Home (Korean Ver.)	\N
238	Make a Wish (Birthday Song) (English Ver.)	\N
238	Interlude: Present to Future	\N
238	Work It	\N
238	All About You	\N
238	I.O.U.	\N
238	Outro: Dream Routine	\N
239	Make a Wish (Birthday Song)	\N
239	Misfit	\N
239	Dancing in the Rain	\N
239	Interlude: Past to Present	\N
239	Déjà Vu	\N
240	Timeless	\N
240	INTRO: Neo Got My Back	\N
240	BOSS	\N
240	Baby Don't Stop	\N
240	GO	\N
240	TOUCH	\N
240	YESTODAY	\N
240	Black on Black	\N
240	The 7th Sense	\N
240	Without You	\N
240	Without You (Chinese Ver.)	\N
240	Dream in a Dream (Ten Solo)	\N
240	OUTRO: VISION	\N
240	YESTODAY - Extended Version	\N
241	Pinky Up	\N
250	Be My Love	\N
250	Be My Love (Inst.)	\N
251	Paper Cuts	\N
252	CBX	\N
252	Ka-CHING!	\N
252	Horololo	\N
252	Girl Problems	\N
252	Shake	\N
252	Off The Wall	\N
252	Ringa Ringa Ring	\N
252	Gentleman	\N
252	Watch Out	\N
252	Cry	\N
252	In This World	\N
253	Beautiful World	\N
254	Monday Blues	\N
254	Blooming Day	\N
254	Sweet Dreams	\N
254	Thursday	\N
254	Vroom Vroom	\N
254	Playdate	\N
254	Lazy	\N
255	Someone Like You	\N
255	Someone Like You (Inst.)	\N
256	Cry	\N
257	It's Running Time!	\N
258	Girl Problems	\N
258	Ka-CHING!	\N
258	Hey Mama!	\N
258	Tornado Spiral	\N
258	Miss You	\N
258	Diamond Crystal	\N
258	KING and QUEEN	\N
259	CRUSH U (with Yoonsang)	\N
260	Beat It Up	\N
260	Rush	\N
260	Cold Coffee	\N
260	Butterflies	\N
260	Tempo	\N
260	TRICKY	\N
261	BTTF	\N
261	CHILLER	\N
261	I LIKE IT	\N
261	DREAM TEAM	\N
261	Interlude : Back to Our Paradise	\N
261	’Bout You	\N
261	That Summer	\N
261	Miss Me	\N
261	Beautiful Sailing	\N
262	INTRO : DREAMSCAPE	\N
262	When I’m With You	\N
262	Flying Kiss	\N
262	i hate fruits	\N
262	No Escape	\N
262	Best of Me	\N
262	YOU	\N
262	Heavenly	\N
262	Night Poem	\N
262	Off The Wall	\N
262	Rains in Heaven	\N
263	Hello Future - KENZIE RE:WORKS	\N
264	Rains in Heaven	\N
265	Moonlight	\N
265	Stupid Cupid	\N
266	Smoothie	\N
266	icantfeelanything	\N
266	BOX	\N
266	Carat Cake	\N
266	UNKNOWN	\N
266	Breathing	\N
267	NCT DREAM, JVKE 'Broken Melodies (JVKE Remix)' (Official Audio)	\N
267	NCT DREAM 엔시티 드림 'Broken Melodies' MV	\N
268	Crescendo	\N
268	Heavy Serenade	\N
268	IDESERVEIT	\N
268	Different Girl	\N
268	Superior	\N
268	LOUD	\N
269	TIC TIC (feat. Pabllo Vittar)	\N
270	[제4차 사랑혁명] 엔믹스(NMIXX) 배이 - Up&Down MV ㅣOSTㅣ웨이브 오리지널	\N
270	Up & Down (Inst.)	\N
271	MEXE (feat. Cobrah & NMIXX)	\N
271	Mexe (feat. NMIXX) (Miss Tacacá & LOFIHOUSEBOY Remix)	\N
271	MEXE	\N
272	NMIXX(엔믹스) “Blue Valentine” M/V	\N
272	Blue Valentine (English Ver.)	\N
272	Blue Valentine (A Cappella Ver.)	\N
272	Blue Valentine (Sped Up Ver.)	\N
272	Blue Valentine (Inst.)	\N
273	Blue Valentine	\N
273	SPINNIN’ ON IT	\N
273	Phoenix	\N
273	Reality Hurts	\N
273	RICO	\N
273	Game Face	\N
273	PODIUM	\N
273	Crush On You	\N
273	ADORE U	\N
273	Shape of Love	\N
273	O.O Part 1 (Baila)	\N
273	O.O Part 2 (Superhero)	\N
274	MEXE	\N
275	릴리 (NMIXX) & 지우 (NMIXX) & 규진 (NMIXX) - Ridin′ (Prod. THE HUB)｜ WSWF｜Lyric Video｜Stone Music Playlist	\N
276	KNOW ABOUT ME	\N
276	Slingshot	\N
276	Golden Recipe	\N
276	Papillon	\N
276	Ocean	\N
276	NMIXX(엔믹스) “High Horse” (Official Audio)	\N
277	RUDE! (Japanese Ver.)	\N
278	Lemon Tang	\N
278	15-LOVE	\N
278	Baby Steps	\N
278	heart emoji (♡)	\N
278	Secret Recipe	\N
278	RUDE!	\N
279	RUDE! (Silly Silky Remix)(feat.Silly Silky)	\N
279	RUDE! (yunji Remix)	\N
280	Rude! (Japanese Ver.)	\N
281	RUDE!	\N
282	The Chase (0to Remix)	\N
282	The Chase (YOHAN Remix)	\N
282	The Chase (SONGUN Remix)	\N
282	The Chase (Arti & Suchan Kim Remix)	\N
282	The Chase (SOR Remix)	\N
283	FOCUS (Jaebin Remix)	\N
283	FOCUS (DJ Seinfeld Remix)	\N
283	FOCUS (Young Franco Remix)	\N
283	FOCUS (sooyeon Remix)	\N
283	Hearts2Hearts 하츠투하츠 'FOCUS' MV	\N
284	FOCUS	\N
284	Apple Pie	\N
284	Pretty Please	\N
284	Flutter	\N
284	Blue Moon	\N
286	STYLE	\N
287	My Christmas Sweet Love	\N
287	Jazz Bar (Carol ver.)	\N
287	Wonderland (Carol ver.)	\N
288	Intro : 7' Dreamcatcher	\N
288	JUSTICE	\N
288	STΦMP!	\N
288	2 Rings	\N
288	Fireflies	\N
289	Lullaby (2024 Concert Ver.)	\N
289	The curse of the Spider (2024 Concert Ver.)	\N
290	Intro : This My Fashion	\N
290	OOTD	\N
290	Rising	\N
290	Shatter	\N
290	We Are Young	\N
291	Dreamcatcher(드림캐쳐) 'BONVOYAGE (Farewell Ver.)' MV (Lyrics)	\N
292	Intro : From us	\N
292	BONVOYAGE	\N
292	DEMIAN	\N
292	Propose	\N
292	To. You	\N
293	REASON	\N
293	REASON (Inst.)	\N
294	Intro : Chaotical X	\N
294	VISION	\N
294	Fairytale	\N
294	Some Love	\N
294	Rainy Day	\N
294	Outro : Mother Nature	\N
295	Intro : Save us	\N
295	Locked Inside A Door	\N
295	MAISON	\N
295	Starlight	\N
295	Together	\N
295	Always	\N
295	Skit : The seven doors	\N
295	Cherry (Real Miracle) (JI U SOLO)	\N
295	No Dot (SU A SOLO)	\N
295	Entrancing (SIYEON SOLO)	\N
295	Winter (HANDONG SOLO)	\N
295	For (YOOHYEON SOLO)	\N
295	Beauty Full (DAMI SOLO)	\N
295	Playground (GAHYEON SOLO)	\N
296	Intro	\N
296	BEcause	\N
296	Airplane	\N
296	Whistle	\N
296	Alldaylong	\N
296	A Heart of Sunflower	\N
298	UNIQUE	\N
298	Pandemonium	\N
298	L.O.Y.L.	\N
298	Wednesday Girl	\N
298	Triple 7	\N
298	ICE (VVS)	\N
299	EX	\N
299	Dancing Queen	\N
299	Stupid Brain	\N
299	Night Of My Life	\N
299	EX (Spanish ver.)	\N
300	DUH!	\N
300	Pretty Boy	\N
300	Murmur	\N
300	Flashy	\N
300	Work	\N
300	Over And Over	\N
301	R.O.P (Reign of Peace) (Prod. Czaer)	\N
301	R.O.P (Reign of Peace) (Instrumental) (Prod. Czaer)	\N
302	SAD SONG	\N
302	It's Alright	\N
302	Last Call	\N
302	Welcome To	\N
302	All You	\N
302	WASP	\N
302	SAD SONG (English Ver.)	\N
303	Killin' It (English Version) (때깔 (Killin' It) (English Version))	\N
304	Killin' It	\N
304	Late Night Calls	\N
304	Everybody Clap	\N
304	Love Story	\N
304	Countdown To Love	\N
304	Emergency	\N
304	2Nite	\N
304	Let Me Love You	\N
304	Street Star	\N
304	I See U	\N
305	Fall In Love Again (Prod. by C. “Tricky” Stewart & Believve)	\N
306	JUMP (English Version)	\N
307	NCT U 엔시티 유 'Do It (Let’s Play)' NCT ZONE OST Making Video	\N
308	Marine Turtle	\N
308	Marine Turtle (Korean Ver.)	\N
308	Marine Turtle (Instrumental)	\N
309	N.Y.C.T	\N
309	N.Y.C.T (Inst.)	\N
310	Rain Day	\N
310	Rain Day (Inst.)	\N
311	coNEXTion (Age of Light)	\N
312	Universe (Let's Play Ball)	\N
313	Coming Home	\N
313	Coming Home (Inst.)	\N
314	LUMINOUS	\N
314	SICK LOVE	\N
314	Hi High (Japanese Version)	\N
315	The Journey	\N
315	Flip That	\N
315	Need U	\N
315	POSE	\N
315	Pale Blue Dot	\N
315	Playback	\N
316	JINAON (Epilogue)(feat.Hyolyn,Yuna,Seola,Eunha,HeeJin,Yeseo)	\N
317	Waka Boom (My Way)(feat.Hyolyn,Lee Young-ji)	\N
317	AURA(feat.WJSN)	\N
317	THE GIRLS (Can't turn me down)(feat.Kep1er)	\N
317	Red Sun!(feat.VIVIZ)	\N
317	POSE(feat.LOONA)	\N
317	Whistle(feat.BB GIRLS)	\N
318	Butterfly(feat.LOONA)	\N
318	Red Sun (Remix)(feat.BB GIRLS)	\N
318	See Sea, BAE(feat.Hyolyn)	\N
319	Purr(feat.SinB,Umji,Xiaoting,Dayeon,Hikaru)	\N
319	KA-BOOM!(feat.Hyolyn,Eunseo,Yeoreum)	\N
319	Tell me now(feat.Eunji,Yves,HeeJin,Choerry,HyeJu)	\N
320	Don't Go (Queendom2 Ver.)(feat.JinSoul,HaSeul,Kim Lip,Chuu,Chaehyun,Youngeun)	\N
321	NAVILLERA(feat.WJSN)	\N
321	SHAKE IT(feat.LOONA)	\N
321	MVSK (Remix)(feat.BB GIRLS)	\N
322	WA DA DA (QUEENDOM2 Ver.)(feat.Kep1er)	\N
322	Chi Mat Ba Ram+Rollin' (Remix)(feat.BB GIRLS)	\N
322	As You Wish(feat.WJSN)	\N
322	PTT (Paint The Town)(feat.LOONA)	\N
323	Yummy-Yummy	\N
323	Yummy-Yummy - Instrumental	\N
324	Blooming (Intro)	\N
324	4 Flowers	\N
324	4 Flowers (Acoustic Remix)	\N
324	4 Flowers (Latin Remix)	\N
324	4 Flowers (Inst.)	\N
325	MMM Simile (Live ver.)	\N
325	MMM Simile (Inst.)	\N
326	ILLELLA	\N
326	L.I.E.C (L.I.E.C)	\N
326	1,2,3 Eoi!	\N
327	Where Are We Now -Japanese ver.-	\N
327	Another Day (내일의 너, 오늘의 나 (Another Day))	\N
327	A Memory for Life (애써 (A Memory for Life))	\N
327	Destiny Part.2 (우린 결국 다시 만날 운명이었지 Part.2 (Destiny Part.2))	\N
327	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
327	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
327	MAMAMOO「mumumumuch -Japanese ver.-」 Music Video	\N
327	Strange Day	\N
328	Paint Me (Orchestra ver.) (칠해줘 (Paint Me) (Orchestra ver.))	\N
328	Starry Night (Orchestra ver.) (별이 빛나는 밤 (Starry Night) (Orchestra ver.))	\N
328	gogobebe (Rock ver.) (고고베베 (gogobebe) (Rock ver.))	\N
328	Egotistic (Blistering sun ver.) (너나 해 (Egotistic) (Blistering sun ver.))	\N
328	You’re the best 2021 (넌 is 뭔들 2021 (You’re the best 2021))	\N
328	I Miss You 2021 (I Miss You 2021)	\N
328	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
328	HeeHeeHaHeHo Part.2 (히히하헤호 Part.2 (HeeHeeHaHeHo Part.2))	\N
328	Words Don't Come Easy 2021 (우리끼리 2021 (Words Don't Come Easy 2021))	\N
328	Piano Man 2021 (Piano Man 2021)	\N
328	AHH OOP 2021 (AHH OOP 2021)	\N
328	Decalcomanie 2021 (Decalcomanie 2021)	\N
328	AYA (Traditional ver.) (AYA (Traditional ver.))	\N
328	HIP (Remix ver.) (HIP (Remix ver.))	\N
328	A little bit 2021 (따끔 2021 (A little bit 2021))	\N
328	Wind flower (Dramatic ver.) (Wind flower (Dramatic ver.))	\N
328	Um Oh Ah Yeh 2021 (음오아예 2021 (Um Oh Ah Yeh 2021))	\N
328	Don’t Be Happy 2021 (행복하지마 2021 (Don’t Be Happy 2021))	\N
328	Peppermint Chocolate (MMM ver.) (썸남썸녀 (Peppermint Chocolate) (MMM ver.))	\N
328	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
328	Destiny (Extended ver.) (우린 결국 다시 만날 운명이었지 (Destiny) (Extended ver.))	\N
328	Mr. Ambiguous 2021 (Mr.애매모호 2021 (Mr. Ambiguous 2021))	\N
328	Yes I am (Funk boost ver.) (나로 말할 것 같으면 (Yes I am) (Funk boost ver.))	\N
329	Where Are We Now	\N
329	Another Day	\N
329	A Memory for Life	\N
329	Destiny Part.2	\N
330	MAMAMOO - WANNA BE MYSELF	\N
330	[MV] 마마무 (MAMAMOO) - 딩가딩가 (Dingga)	\N
330	MAMAMOO - AYA	\N
330	MAMAMOO - Travel	\N
330	MAMAMOO - Chuck	\N
330	MAMAMOO - Diamond	\N
330	MAMAMOO - Good Night	\N
330	MAMAMOO - AYA (Japanese Ver.)	\N
330	MAMAMOO - Dingga (Japanese Ver.)	\N
330	MAMAMOO - Just Believe in Love	\N
331	Travel	\N
331	Dingga	\N
331	AYA	\N
331	Chuck	\N
331	Diamond	\N
331	Good Night	\N
332	Dingga	\N
332	Dingga (Inst.)	\N
333	WANNA BE MYSELF	\N
333	WANNA BE MYSELF (Inst.)	\N
334	Season of Memories	\N
334	Always	\N
335	GFRIEND (여자친구) '우리의 다정한 계절 속에' OFFICIAL MV	\N
336	MAGO	\N
336	Love Spell	\N
336	Three Of Cups	\N
336	GRWM	\N
336	Secret Diary	\N
336	Better Me	\N
336	Night Drive	\N
336	GFRIEND - Apple	\N
336	GFRIEND - Crossroads	\N
336	GFRIEND - Labyrinth	\N
336	GFRIEND - Wheel of the year	\N
337	Apple	\N
337	Eye of The Storm	\N
337	Room of Mirrors	\N
337	Tarot Cards	\N
337	Crème Brulée	\N
337	Stairs In The North	\N
338	Labyrinth	\N
338	GFRIEND (여자친구) '교차로 (Crossroads)' Official M/V	\N
338	Here We Are	\N
338	지금 만나러 갑니다 (Eclipse)	\N
338	Dreamcatcher	\N
338	From Me	\N
339	Crème Brûlée	\N
339	Stairs in the North	\N
340	Crossroads	\N
340	Eclipse	\N
341	Fallin' Light	\N
341	Memoria	\N
341	FLOWER	\N
341	SUNRISE -JP ver.-	\N
342	Fever	\N
342	Mr. Blue	\N
342	Smile	\N
342	Wish	\N
342	Paradise	\N
342	Hope	\N
342	FLOWER - Korean Version	\N
342	Fever - Instrumental	\N
343	GFRIEND - Cheers (ZZAN)	\N
344	Memory of the Moon	\N
345	Twilight	\N
346	Circles	\N
347	U&Iverse	\N
348	Candy Sugar Pop	\N
348	Something Something	\N
348	More	\N
348	Light the sky	\N
348	Story	\N
348	All Day	\N
348	First Love	\N
348	Let's go ride	\N
348	S#1.	\N
348	24 Hours	\N
348	Like stars	\N
349	Ichiban Suki na Hito ni Sayonara wo Iou	\N
349	Ichiban Suki na Hito ni Sayonara wo Iou (Inst.)	\N
350	ALIVE	\N
351	All Good-JP Ver.-	\N
352	After Midnight	\N
352	Footprint	\N
352	Waterfall	\N
352	Sunset Sky	\N
352	MY ZONE	\N
352	Don’t Worry	\N
353	Dear my universe	\N
353	Butterfly Effect	\N
353	ONE	\N
353	Someone Else	\N
353	SNS	\N
353	All Good	\N
353	All Stars	\N
353	Our spring	\N
353	Stardust	\N
353	gemini	\N
354	Still Life	\N
355	Flower Road	\N
356	FXXK IT	\N
356	LAST DANCE	\N
356	GIRL FRIEND	\N
356	LET'S NOT FALL IN LOVE	\N
356	LOSER	\N
356	BAE BAE	\N
356	BANG BANG BANG	\N
356	SOBER	\N
356	IF YOU	\N
356	ZUTTER (GD&T.O.P)	\N
356	WE LIKE 2 PARTY	\N
359	If you	\N
359	SOBER	\N
360	BANG BANG BANG	\N
360	We like 2 party	\N
361	LOSER	\N
361	BAE BAE	\N
362	Still Alive	\N
362	MONSTER	\N
362	Feeling	\N
362	FANTASTIC BABY	\N
362	BAD BOY	\N
362	BLUE	\N
362	Bingle Bingle	\N
362	Ego	\N
362	Love Dust	\N
362	Monster (Inst.)	\N
363	Intro (Alive)	\N
363	BLUE	\N
363	Love Dust	\N
363	BAD BOY	\N
363	Ain't No Fun	\N
363	FANTASTIC BABY	\N
363	Wings (Daesung Solo)	\N
364	06070	\N
364	VIRAL	\N
364	ddok ddok ddok	\N
364	ADIOS!	\N
364	Upside Down	\N
364	DIVE	\N
364	Forever You	\N
364	I Wonder	\N
365	KNOCK KNOCK KNOCK	\N
366	No Doubt	\N
366	No Doubt (Inst.)	\N
367	Earth, Wind & Fire (Buldak Hotter Than My EX Ver.)	\N
368	Nice Guy (Live Ver.)	\N
368	Serenade (Live Ver.)	\N
368	123-78 (Live Ver.)	\N
368	OUR (Live Ver.)	\N
368	l i f e i s c o o l (Live Ver.)	\N
368	But I Like You (Live Ver.)	\N
368	One and Only (Live Ver.)	\N
368	Step By Step (Live Ver.)	\N
368	IF I SAY, I LOVE YOU (Live Ver.)	\N
368	I Feel Good (Live Ver.)	\N
368	Dangerous (Live Ver.)	\N
368	But Sometimes (Live Ver.)	\N
368	Crying (Live Ver.)	\N
368	Dear. My Darling (Live Ver.)	\N
368	Gonna Be A Rock (Live Ver.)	\N
368	Earth, Wind & Fire (Live Ver.)	\N
369	SAY CHEESE!	\N
370	Live In Paris	\N
370	Hollywood Action	\N
370	JAM!	\N
370	Bathroom	\N
370	As Time Goes By	\N
371	Count To Love	\N
371	I Feel Good (Japanese Version)	\N
371	Nice Guy (Japanese Version)	\N
371	Dangerous (Japanese Version)	\N
372	123-78	\N
372	I Feel Good	\N
372	Step By Step	\N
372	Is That True?	\N
372	Next Mistake	\N
372	IF I SAY, I LOVE YOU	\N
372	I Feel Good (English Ver.)	\N
373	Never Loved This Way Before	\N
373	Never Loved This Way Before (Instrumental)	\N
374	4SHO 4SHO	\N
374	YEAH YEAH!	\N
374	NO HI, NO HEY	\N
374	RUN IT UP	\N
374	GGUKBONG	\N
374	MOYA	\N
374	THE PURGE 4SHOMIX	\N
374	PUBLIC ENEMY 4SHOMIX(feat.DJ Wegun)	\N
375	Good Girls (Louis Solo)	\N
375	Boo Thang (Woojin Solo)	\N
375	Summer Eyes (Ohyul Solo)	\N
375	For Us (Ryul Solo)	\N
375	Vanilla Days	\N
376	Are You Ready	\N
376	Trust Myself	\N
376	Thinking	\N
376	All Good	\N
376	Ejeh	\N
376	Next 2 U	\N
376	My Side	\N
376	Next 2 U (Sped Up)	\N
376	Next 2 U (Carol Remix)	\N
376	Next 2 U (Carol Remix) (Sped Up)	\N
377	Saucin’	\N
377	Moonwalkin	\N
377	FaceTime	\N
377	Backseat	\N
377	Never Let Go	\N
378	Saucin’	\N
379	iKON - "PANORAMA" MV	\N
379	T.T.M	\N
380	U	\N
380	Tantara	\N
380	RUM PUM PUM	\N
380	Like a Movie	\N
380	Driving Slowly	\N
380	Never Forget You	\N
380	All The Way Here	\N
380	FIGHTING - SONG SOLO	\N
380	Kiss Me - DK SOLO	\N
380	Want You Back - JU-NE SOLO	\N
381	BUT YOU	\N
381	DRAGON	\N
381	FOR REAL?	\N
381	GOLD	\N
381	NAME	\N
382	At ease	\N
383	Why Why Why	\N
384	Ah Yeah	\N
384	Dive	\N
384	All The World	\N
384	Holding On	\N
384	Flower	\N
385	I'm OK	\N
386	GOODBYE ROAD	\N
386	Don't Let Me Know	\N
386	ADORE YOU	\N
386	PERFECT	\N
387	KILLING ME	\N
387	Freedom	\N
387	Only You	\N
387	Cocktail	\N
387	Just For You	\N
388	Rubber Band	\N
389	THE RULES	\N
389	SERVE	\N
389	Extancy (Wumuti & Rui)	\N
389	BACK 2 BACK	\N
389	HIPS (Hyun & Haru)	\N
389	Masterpiece	\N
389	SERVE (Inst.)	\N
390	Rizz	\N
390	Scent	\N
390	Dirty Baby	\N
390	Biii:-P	\N
390	Kiss and say goodbye	\N
390	Drip Drip	\N
391	1&Only	\N
391	1 of LOV	\N
391	BIZNESS	\N
391	1 & Only (Instrumental)	\N
391	1 of LOV (Instrumental)	\N
391	BIZNESS (Instrumental)	\N
392	I’mma Be	\N
392	I'mma Be (88 Techno Remix by dxp)	\N
392	I'mma Be (Dark House Remix by dxp)	\N
392	I'mma Be (Backing Track)	\N
394	Intro.	\N
394	TOP 5	\N
394	V For Vision	\N
394	Customize	\N
394	Exotic	\N
394	Changes	\N
394	Zero To Hundred	\N
395	Running to Future	\N
395	ROSES	\N
395	LOVEPOCALYPSE	\N
396	ROSES	\N
398	ICONIK (Japanese ver.)	\N
398	SLAM DUNK (Japanese ver.)	\N
398	BLUE (Japanese ver.)	\N
399	ICONIK	\N
399	SLAM DUNK	\N
399	Lovesick Game	\N
399	Goosebumps	\N
399	Dumb	\N
399	NOW OR NEVER (Korean ver.)	\N
399	EXTRA(feat.Sung Han Bin,Seok Matthew,Kim Gyu Vin,Park Gun Wook,Han Yu Jin)	\N
399	Long Way Back(feat.Kim Ji Woong,Zhang Hao,Kim Tae Rae,Ricky)	\N
399	Star Eyes	\N
399	I Know U Know	\N
400	D-DAY (ZEROBASEONE)	\N
400	UPSIDE DOWN (YOUNG POSSE)	\N
400	Goodbye (Choo Young-woo)	\N
400	Better with you (Colde)	\N
400	When we meet again (Miyeon)	\N
400	Close to You  (CHEEZE)	\N
400	Burden (Jo Hyun-ah)	\N
400	D-DAY (Instrumental)	\N
400	UPSIDE DOWN (Instrumental)	\N
400	Goodbye (Instrumental)	\N
400	Better with you (Instrumental)	\N
400	When we meet again (Instrumental)	\N
400	Close To You (Instrumental)	\N
400	Burden (Instrumental)	\N
402	D-DAY	\N
402	D-DAY (Inst.)	\N
403	ZERO:ATTITUDE	\N
404	D-D-DANCE	\N
405	Mis-en-Scène	\N
405	Panorama	\N
405	Island	\N
405	Sequence	\N
405	O Sole Mio	\N
405	느린여행 Slow Journey	\N
406	Beware	\N
406	Vampire	\N
406	好きと言わせたい Suki to Iwasetai	\N
406	Waiting	\N
406	Buenos Aires	\N
406	好きになっちゃうだろう? Suki ni Nacchaudarou? (IZ*ONE Version)	\N
406	Yummy Summer(feat.Sakura,Kim Chaewon,Minju,Yujin)	\N
406	La Vie en Rose (Japanese Version)	\N
406	Violeta (Japanese Version)	\N
406	FIESTA (Japanese Version)	\N
406	夢を見ている間 Yume wo Miteiru Aida (Japanese Version)	\N
406	どうすればいい? Dousurebaii?(feat.Kwon Eunbi,Yena,Hitomi,Wonyoung)	\N
406	Shy Boy(feat.Kang Hyewon,Lee Chae Yeon,Nako,Jo Yuri)	\N
407	Welcome	\N
407	환상동화 Secret Story of the Swan	\N
407	Pretty	\N
407	회전목마 Merry-Go-Round	\N
407	Rococo	\N
407	With*One	\N
407	Secret Story of the Swan - Japanese Ver.	\N
407	Merry-Go-Round - Japanese Ver.	\N
408	EYES	\N
408	FIESTA	\N
408	DREAMLIKE(feat.Kwon Eunbi,Sakura,Kang Hyewon,Yena,Hitomi,Wonyoung)	\N
408	AYAYAYA(feat.Kwon Eunbi,Sakura,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Jo Yuri,Yujin)	\N
408	SO CURIOUS(feat.Yena,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Hitomi,Jo Yuri,Yujin,Wonyoung)	\N
408	SPACESHIP	\N
408	우연이 아니야 DESTINY	\N
408	YOU & I	\N
408	DAYDREAM(feat.Kwon Eunbi,Lee Chae Yeon,Minju,Yujin)	\N
408	PINK BLUSHER(feat.Sakura,Kang Hyewon,Nako,Hitomi,Wonyoung)	\N
408	언젠가 우리의 밤도 지나가겠죠 SOMEDAY(feat.Yena,Kim Chaewon,Jo Yuri)	\N
408	OPEN YOUR EYES	\N
409	Vampire	\N
409	君以外 (Kimi Igai)	\N
409	Love Bubble(feat.Kwon Eunbi,Sakura,Kang Hyewon,Hitomi,Kim Chaewon,Jo Yuri)	\N
409	紫外線なんかぶっとばせ (Shigaisennanka Buttobase)(feat.Yena,Wonyoung,Lee Chae Yeon,Nako,Yujin,Minju)	\N
409	不機嫌Lucy (Fukigen Lucy)(feat.Yena,Lee Chae Yeon)	\N
410	Buenos Aires	\N
410	Tomorrow	\N
410	Target(feat.Kwon Eunbi,Yujin,Lee Chae Yeon,Sakura,Minju,Kang Hyewon)	\N
410	年下Boyfriend (Toshishita Boyfriend)(feat.Yena,Jo Yuri,Kim Chaewon,Wonyoung,Nako,Hitomi)	\N
410	Human Love(feat.Jo Yuri,Yujin)	\N
411	해바라기 Hey. Bae. Like it.	\N
411	비올레타 Violeta	\N
411	Highlight	\N
411	Really Like You	\N
411	Airplane	\N
411	하늘 위로 Up	\N
411	고양이가 되고 싶어 NEKONI NARITAI (Korean Ver.)	\N
411	기분 좋은 안녕 GOKIGEN SAYONARA (Korean Ver.)	\N
412	好きと言わせたい (Suki to Iwasetai)	\N
412	ケンチャナヨ (Gwaen Chanha Yo)	\N
412	ご機嫌サヨナラ (Gokigen Sayonara)(feat.Wonyoung,Yujin,Kwon Eunbi,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Hitomi)	\N
412	猫になりたい (Neko ni Naritai)(feat.Sakura,Yena,Jo Yuri,Nako,Minju)	\N
412	ダンスを思い出すまで (Dance o Omoidasumade)(feat.Wonyoung,Sakura)	\N
414	We on Fire	\N
414	Bewitched	\N
414	HOTLINE	\N
414	Sakura-iro Yell	\N
414	We on Fire (Korean Ver.)	\N
414	Bewitched (Korean Ver.)	\N
415	Back to Life	\N
415	Lunatic	\N
415	MISMATCH	\N
415	Rush	\N
415	Heartbreak Time Machine	\N
415	Who am I	\N
416	Go in Blind	\N
416	Run Wild	\N
416	Wolf type	\N
416	Extraordinary day	\N
416	Go in Blind (Korean ver.)	\N
416	Run Wild (Korean ver.)	\N
417	Extraordinary day	\N
418	Magic Hour	\N
418	&TEAM 'Wonderful World' Focus Cam (방과후 ver.)	\N
419	Yukiakari	\N
419	Deer Hunter	\N
419	Illumination	\N
419	Crescent moon’s wish	\N
419	Samidare	\N
419	Scar to Scar	\N
419	Maybe	\N
419	Aoarashi	\N
419	Koegawari	\N
419	Imprinted	\N
419	Jyuugoya	\N
419	Big Suki	\N
419	Beat the Odds	\N
419	MEME	\N
419	Samidare (Korean ver.)	\N
419	Scar to Scar (Korean ver.)	\N
419	Aoarashi (Korean ver.)	\N
419	Koegawari (Korean ver.)	\N
419	Yukiakari (Korean ver.)	\N
419	Deer Hunter (Korean ver.)	\N
419	Dropkick (Korean ver.)	\N
419	Feel the Pulse	\N
420	Jyuugoya	\N
420	Big suki	\N
422	Beat the odds	\N
423	BREAKOUT	\N
423	FOCUS	\N
423	CODE	\N
423	Can't Be Broken	\N
424	Zombie	\N
424	Colourz	\N
424	Back 2 Luv	\N
425	SLAY	\N
425	Oh Ma Ma God	\N
425	Make Me Feel	\N
427	TheFatRat & EVERGLOW - Ghost Light	\N
427	Ghost Light (Korean)	\N
427	Ghost Light (Sped Up)	\N
427	Ghost Light (Instrumental)	\N
427	Ghost Light (Slowed Down Reverb)	\N
428	EVERGLOW - Pirate (R3HAB Remix) (Official Visualizer)	\N
429	Back Together	\N
429	Pirate	\N
429	Don’t Speak	\N
429	Nighty Night	\N
429	Company	\N
430	PROMISE (for UNICEF PROMISE CAMPAIGN)	\N
431	FIRST	\N
431	DON′T ASK DON′T TELL	\N
431	PLEASE PLEASE	\N
432	Let Me Dance	\N
432	Let Me Dance (Instrumental)	\N
433	Baby Flower (Seoul Remix : Vendors)	\N
433	Baby Flower (Bangkok Remix : Kurtz)	\N
433	Baby Flower (Taipei Remix : ntrophy)	\N
433	Baby Flower (Tokyo Remix : Full8loom)	\N
434	Baby Flower -Japanese Ver.- - Baby Flower Japanese Version	\N
435	Sad Girls Schemin'	\N
435	Peer	\N
435	Baby Flower	\N
435	Type of Girl	\N
435	Sleek	\N
435	I Like That	\N
435	Me Myself Mode	\N
436	Tokimetique	\N
436	Tokimetique -Shin Sakiura Remix-	\N
436	Tokimetique TV Edit	\N
437	Are You Alive (깨어) (Inst.)	\N
437	Detective Soseol (추리소설) (Inst.)	\N
437	Firework Diary (어제 우리 불꽃놀이) (Inst.)	\N
437	Love Child (Inst.)	\N
437	Persona (Inst.)	\N
437	Too Hot (Inst.)	\N
437	Diablo (Inst.)	\N
437	Friend Zone (Inst.)	\N
437	Love2Love (Inst.)	\N
437	Fly Up (Inst.)	\N
437	Cameo Love (Inst.)	\N
437	Bubble Gum Girl (Inst.)	\N
437	Q&A (Inst.)	\N
437	Christmas Alone (Inst.)	\N
438	Magic Shine New Zone	\N
438	Fly Up(feat.neptune)	\N
438	Cameo Love(feat.moon)	\N
438	Bubble Gum Girl(feat.sun)	\N
438	Q&A(feat.zenith)	\N
438	Christmas Alone	\N
439	Password	\N
439	ヘッドフォン - Headphones	\N
439	トキメティック - Tokimetique	\N
439	TOKYO	\N
439	Oshare	\N
439	アンタイトル - Untitled	\N
439	### (∞! Ver.)	\N
440	Password	\N
441	Pink Power	\N
441	Pink Power (inst.)	\N
442	@% (Alpha Percent)	\N
442	깨어 (Are You Alive)	\N
442	추리소설 (Detective Soseol)	\N
442	어제 우리 불꽃놀이 (Firework Diary)	\N
442	Love Child	\N
442	Persona	\N
442	Too Hot	\N
442	Diablo	\N
442	Friend Zone	\N
442	Love2Love	\N
443	SUPER JUNIOR 슈퍼주니어 'Express Mode' MV	\N
443	Haircut	\N
443	Air	\N
443	Delight	\N
443	I Know	\N
443	Say Less	\N
443	D.N.A.	\N
443	Finale	\N
443	우리의 꽃말 Stuck With You	\N
444	Show Time	\N
445	Celebrate	\N
445	Hate Christmas	\N
445	Snowman	\N
445	White Love	\N
445	If only you (Special Track)	\N
446	Mango	\N
446	Don't Wait	\N
446	My Wish	\N
446	Everyday	\N
446	Always	\N
447	Callin' (Winter for Spring ver.)	\N
447	Analogue Radio	\N
447	Callin' (Inst.)	\N
447	Analogue Radio (Inst.)	\N
448	SUPER	\N
448	House Party	\N
448	Burn The Floor	\N
448	Paradox	\N
448	Closer	\N
448	The Melody	\N
448	Raining Spell for Love (Remake Version)	\N
448	Mystery	\N
448	More Days with You	\N
448	Tell Me Baby	\N
449	MAMACITA -AYAYA- -Japanese Version-	\N
449	Black Suit - Japanese Ver.	\N
449	Devil - Japanese Ver.	\N
449	I Think I	\N
449	One More Time (Otra Vez) (feat. REIK) - Japanese Ver.	\N
449	On and On	\N
449	Blue World	\N
449	Magic - Japanese Ver.	\N
449	Wow! Wow!! Wow!!!	\N
449	Star	\N
449	MOTORCYCLE	\N
449	Saturday Night	\N
449	JOIN HANDS	\N
449	Let's Get It On	\N
449	Celebration～君に架ける橋～	\N
449	雨のち晴れの空の色	\N
449	僕のまじめなラブコメディー	\N
449	Splash	\N
449	Sunrise	\N
449	Because I Love You ～大切な絆～	\N
449	桜の花が咲く頃	\N
449	Coming Home	\N
450	XIGNAL (The Intro)	\N
450	GALA	\N
450	ROCK THE BOAT	\N
450	TAKE MY BREATH	\N
450	NO GOOD	\N
450	HYPNOTIZE	\N
450	UP NOW	\N
450	O.R.B (Obviously Reads Bro)	\N
450	4 SEASONS	\N
450	PS118	\N
451	XG - GALA (Official Music Video)	\N
451	GALA (Instrumental)	\N
452	X-GENE (HESONOO) (XG 1st WORLD TOUR “The first HOWL” Live)	\N
452	HOWLING & GRL GVNG [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	UNDEFEATED [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	TGIF & IYKYK [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	Tippy Toes & SOMETHING AIN’T RIGHT & IN THE RAIN [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	SHOOTING STAR [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	WOKE UP [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	PUPPET SHOW [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	XG - IS THIS LOVE (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
452	XG - NEW DANCE (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
452	XG - MILLION PLACES (from XG 1st WORLD TOUR "The first HOWL" FINAL Landing at TOKYO DOME)	\N
452	WINTER WITHOUT YOU & MASCARA [XG 1st WORLD TOUR “The first HOWL” Live]	\N
452	LEFT RIGHT [XG 1st WORLD TOUR “The first HOWL” Live]	\N
453	XG - MILLION PLACES (Official Music Video)	\N
453	LEFT RIGHT (Y2K Ver.)	\N
453	PUPPET SHOW (City Pop Ver.) (XG “The first HOWL” Live)	\N
453	MILLION PLACES (Instrumental)	\N
454	XG - IN THE RAIN (Official Music Video)	\N
454	IN THE RAIN x XDM	\N
454	IN THE RAIN (Instrumental)	\N
455	XG - IS THIS LOVE (Official Music Video)	\N
455	IS THIS LOVE (Piano Ver.)	\N
455	IS THIS LOVE (Instrumental)	\N
455	IS THIS LOVE (Piano Ver.) (Instrumental)	\N
456	HESONOO + X-GENE x XDM	\N
456	GRL GVNG x XDM	\N
456	WOKE UP x XDM	\N
456	SOMETHING AIN’T RIGHT x XDM	\N
456	TGIF x XDM	\N
456	PUPPET SHOW x XDM	\N
456	TIPPY TOES x XDM	\N
456	NEW DANCE x XDM	\N
457	WINTER WITHOUT YOU -Orchestra ver.-	\N
457	WINTER WITHOUT YOU -Orchestra ver.- (Instrumental)	\N
458	HOWL	\N
458	HOWLING	\N
458	SPACE MEETING Skit	\N
458	IYKYK	\N
458	SOMETHING AIN'T RIGHT	\N
458	IN THE RAIN	\N
458	WOKE UP REMIXX [PROD BY JAKOPS] (FEAT. Jay Park, OZworld, AKLO, Paloalto, VERBAL, Awich, Tak, Dok2)	\N
458	IS THIS LOVE	\N
459	IYKYK	\N
62	Cosmic	\N
62	Sunflower	\N
62	Last Drop	\N
62	Love Arcade	\N
62	Bubble	\N
62	Night Drive	\N
62	Sweet Dreams	\N
63	Cosmic	\N
63	Sunflower	\N
63	Last Drop	\N
63	Love Arcade	\N
63	Bubble	\N
63	Night Drive	\N
64	Chill Kill	\N
64	Knock Knock (Who's There?)	\N
64	Underwater	\N
64	Will I Ever See You Again?	\N
64	Nightmare	\N
64	Iced Coffee	\N
64	One Kiss	\N
64	Bulldozer	\N
64	Wings	\N
64	풍경화 Scenery	\N
65	Red Flavor (빨간 맛) (Mar Vista Remix)	\N
66	Beautiful Christmas	\N
67	Birthday	\N
67	BYE BYE	\N
67	On A Ride (롤러코스터)	\N
67	ZOOM	\N
67	Celebrate	\N
68	Marionette	\N
68	WILDSIDE	\N
68	SAPPY	\N
68	Jackpot	\N
68	#Cookie Jar	\N
68	Snap Snap	\N
68	Sayonara	\N
68	Aitai-tai	\N
68	Swimming Pool	\N
68	'Cause it's you	\N
68	Color of Love	\N
69	Tiny Light	\N
70	Where love passed	\N
71	HBD	\N
71	THUNDER	\N
71	Skyfall (THE 8 Solo)	\N
71	Fortunate Change (JOSHUA Solo)	\N
71	99.9% (WONWOO Solo)	\N
71	Raindrops (SEUNGKWAN Solo)	\N
71	Damage (HOSHI Solo) (feat. Timbaland)	\N
71	Shake It Off (MINGYU Solo)	\N
71	Happy Virus (DK Solo)	\N
71	Destiny (WOOZI Solo)	\N
71	Shining Star (Vernon Solo)	\N
71	Gemini (JUN Solo)	\N
71	Trigger (DINO Solo)	\N
71	Coincidence (JEONGHAN Solo)	\N
71	Jungle (S.COUPS Solo)	\N
71	Bad Influence (Prod. by Pharrell Williams)	\N
72	Shohikigen	\N
72	Circles (Japanese ver.)	\N
72	MAESTRO (Japanese ver.)	\N
73	Love, Money, Fame (feat. DJ Khaled)	\N
73	Love, Money, Fame (Kenia OS Remix)	\N
74	Love, Money, Fame (feat. DJ Khaled)	\N
74	Love, Money, Fame (Timbaland Remix)	\N
75	Love, Money, Fame (feat. DJ Khaled)	\N
75	Love, Money, Fame (English Ver.)	\N
75	Love, Money, Fame (Sped Up Ver.)	\N
75	Love, Money, Fame (Hitchhiker Remix)	\N
75	Love, Money, Fame (TAK Remix)	\N
76	Eyes on you	\N
76	LOVE, MONEY, FAME (feat. DJ Khaled)	\N
76	1 TO 13	\N
76	Candy	\N
76	Rain	\N
76	Water	\N
77	MAESTRO	\N
77	MAESTRO (Orchestra Remix)	\N
77	MAESTRO (Inst.)	\N
78	MAESTRO	\N
78	LALALI	\N
78	Spell	\N
78	Cheers to Youth	\N
78	CALL CALL CALL! (Korean Ver.)	\N
78	Happy Ending (Korean Ver.)	\N
78	Fallin' Flower (Korean Ver.)	\N
78	24H (Korean Ver.)	\N
78	Not Alone (Korean Ver.)	\N
78	Power of Love (Korean Ver.)	\N
78	DREAM (Korean Ver.)	\N
78	Ima -Even if the world ends tomorrow- (Korean Ver.)	\N
78	Adore U	\N
78	MANSAE	\N
78	Pretty U	\N
78	VERY NICE	\N
78	BOOMBOOM	\N
78	Don't Wanna Cry	\N
78	CLAP	\N
78	THANKS	\N
78	Oh My!	\N
78	Home	\N
78	Fear	\N
78	Left & Right	\N
78	HOME;RUN	\N
78	Ready to love	\N
78	Rock with you	\N
78	HOT	\N
78	_WORLD	\N
78	'F*ck My Life	\N
78	Super	\N
78	God of Music	\N
78	Adore U (Inst.) (Digital Only)	\N
93	Aura	\N
93	Crazy	\N
93	Not By The Moon	\N
93	Love You Better	\N
93	Trust My Love	\N
93	Poison	\N
94	Sing For U	\N
94	Love Loop	\N
94	Your Space	\N
94	Bibouroku	\N
94	Karma	\N
94	Drunk	\N
95	You Calling My Name	\N
95	Pray	\N
95	Now or Never (feat. Jonas Blue)	\N
95	Thursday	\N
95	Run Away	\N
95	Crash & Burn	\N
96	Love Loop	\N
96	Your Space	\N
96	Bibouroku	\N
96	Karma	\N
96	Drunk	\N
96	#Summervibes	\N
96	Remember Me	\N
96	Superman	\N
96	Love Loop - Instrumental	\N
97	1°	\N
97	Eclipse	\N
97	The End	\N
97	Time Out	\N
97	Believe	\N
97	Page	\N
98	Attitude	\N
99	LEMONADE (2Spade Remix)	\N
99	LEMONADE	\N
100	LEMONADE (Marlon Hoffstadt Remix)	\N
100	LEMONADE (Marlon Hoffstadt Extended Mix)	\N
100	LEMONADE	\N
101	LEMONADE (Zedd Remix)	\N
101	LEMONADE	\N
102	WDA (Whole Different Animal)(feat.G-Dragon)	\N
102	LEMONADE	\N
102	SHAKIN'	\N
102	Can't Help Myself	\N
102	Camouflage	\N
102	Bite	\N
102	Switchblade (feat. Ty Dolla $ign)	\N
102	Roll	\N
102	My Plan	\N
102	'Til We Die	\N
102	LEMONADE (feat. Becky G)	\N
102	LEMONADE (Sped Up Version)	\N
102	LEMONADE (Slowed Down Version)	\N
102	LEMONADE (Instrumental)	\N
102	Voice Memo (KARINA Version)	\N
102	Voice Memo (GISELLE Version)	\N
102	Voice Memo (WINTER Version)	\N
102	Voice Memo (NINGNING Version)	\N
103	Flashing Lights - (with Crush)(feat.Crush)	\N
103	Caution - (with NMIXX)(feat.NMIXX)	\N
103	Aftertaste - (with DEAN)(feat.Dean)	\N
103	PITC (Party in the Corner) - (with Hongjoong & Jay Park)(feat.Hongjoong,Jay Park)	\N
103	Fire With Fire (LNGSHOT)(feat.LNGSHOT)	\N
103	Can't Get Enough	\N
103	Bet On U - (with Chungha)(feat.Chungha)	\N
103	International - (with SOYEON)(feat.Soyeon)	\N
103	What About Us	\N
103	Wanna Buy a Plant + Cost Me - (with JO1)(feat.JO1)	\N
103	Keychain - (with aespa)(feat.aespa)	\N
103	One More Dance - (JOSHUA & Corbyn Besson)	\N
103	Wildcard - (KEVIN WOO)(feat.Kevin)	\N
103	Just One Bite	\N
103	Too Bad (K-POPS! Ver.) - (with G-Dragon)(feat.G-Dragon)	\N
103	Love Is Everywhere	\N
103	The Last	\N
104	WDA (Whole Different Animal)(feat.G-Dragon)	\N
105	ATTITUDE	\N
106	Keychain	\N
107	BLUE - WINTER Solo(feat.Winter)	\N
107	Ketchup And Lemonade - NINGNING Solo(feat.Ningning)	\N
107	Tornado - GISELLE Solo(feat.Giselle)	\N
107	GOOD STUFF - KARINA Solo(feat.Karina)	\N
108	BAD (Ofenbach Ver.)	\N
109	BAD (James Carter Ver.)	\N
110	BAD (Steve Aoki Ver)	\N
111	Bad (Speed Up Ver.)	\N
111	Bad (Speed Down Ver.)	\N
111	Bad (Ollounder Ver.)	\N
111	Bad (LEEZ Ver.)	\N
112	BAD	\N
112	MAMACITA	\N
112	TOXIN	\N
112	Fallin'	\N
112	Body	\N
113	Adrenaline (NO1 Ver.)	\N
113	Adrenaline (Speed Up Ver.)	\N
113	Adrenaline (Speed Down Ver.)	\N
114	Ghost	\N
114	Adrenaline	\N
114	NASA	\N
114	On The Road	\N
114	Choose	\N
115	[MV] ATEEZ(에이티즈) - Waiting For You | 마지막 썸머(Last Summer) OST part 6	\N
115	Waiting for You (Instrumental)	\N
116	[Special Clip] ATEEZ(에이티즈) ‘Choose’	\N
117	Motto (English Ver.)	\N
117	Motto (Band Ver.)	\N
117	Motto (Unplugged Ver.)	\N
117	Motto (Inst.)	\N
118	Motto	\N
118	Glitch	\N
118	You And I	\N
118	Pocket (Yeji)	\N
118	Asylum (Lia)	\N
118	Look (Ryujin)	\N
118	Undefined (Chaeryeong)	\N
118	Tangerine (Yuna)	\N
119	TUNNEL VISION (R.Tee Remix)	\N
119	TUNNEL VISION (IMLAY Remix)	\N
119	TUNNEL VISION (2Spade Remix)	\N
119	TUNNEL VISION (CIFIKA Remix)	\N
119	TUNNEL VISION (English Ver.)	\N
119	TUNNEL VISION (Inst.)	\N
120	Focus	\N
120	TUNNEL VISION	\N
120	DYT	\N
120	Flicker	\N
120	Nocturne	\N
120	8-BIT HEART	\N
121	ROCK & ROLL	\N
121	I. I. Know Me	\N
121	Out of season	\N
121	Trigger	\N
121	Wind Ride	\N
121	Algorhythm (Final Ver.)	\N
121	No Biggie (Final Ver.)	\N
121	GOLD -Japanese ver.-	\N
121	Imaginary Friend -Japanese ver.-	\N
121	Girls Will Be Girls -Japanese ver.-	\N
122	Girls Will Be Girls (English Ver.)	\N
122	Girls Will Be Girls (Tech House Remix)	\N
122	Girls Will Be Girls (EDM Remix)	\N
122	Girls Will Be Girls (Rock Remix)	\N
123	GOLD	\N
123	Imaginary Friend	\N
123	Bad Girls R Us	\N
123	Supernatural	\N
123	FIVE	\N
123	VAY(feat.Changbin)	\N
123	BORN TO BE (Final Ver.)	\N
123	UNTOUCHABLE (Final Ver.)	\N
123	Mr. Vampire (Final Ver.)	\N
123	Dynamite (Final Ver.)	\N
123	Escalator (Final Ver.)	\N
124	Algorhythm	\N
124	No Biggie	\N
124	Algorhythm (Instrumental)	\N
124	No Biggie (Instrumental)	\N
125	Licorice (LOOZBONE Remix)	\N
125	Armageddon (SixThema & Epik Remix)	\N
125	Walk (Arkins Remix)	\N
125	Fact Check (Ezra Hazard Remix)	\N
125	Supernova (Fahjah Remix)	\N
125	Lemonade (RayRay Remix)	\N
125	Whiplash (DJ Long Nhat Remix)	\N
125	Love On The Floor (Aurede Remix)	\N
125	Breakfast (ASHID & 9INE6IX Remix)	\N
126	Show! Show! Show! (duco Remix)	\N
126	Whiplash (monotostereo Remix)	\N
126	UP (KARINA Solo) (Coziest Remix)	\N
126	Flights, Not Feelings (Demicat Remix)	\N
126	Rover (IMLAY Remix)	\N
126	Make A Wish (Birthday Song) (yunji Remix)	\N
126	Siren (Noisyfloor Remix)	\N
126	INVU (Yetsuby Remix)	\N
126	Smoothie (Departs Remix)	\N
126	Fact Check (Spearman Remix)	\N
126	Gas (Demicat Remix)	\N
126	Boom Boom Bass (Arkins Remix)	\N
126	Spark (WINTER Solo) (2Spade Remix)	\N
127	Intro: Wall to Wall	\N
127	Walk	\N
127	No Clue	\N
127	Orange Seoul	\N
127	Pricey	\N
127	Time Capsule	\N
127	Can't Help Myself	\N
127	Rain Drop	\N
127	Gas	\N
127	Suddenly	\N
127	Meaning of Love	\N
129	Be There For Me	\N
129	Home Alone	\N
129	White Lie	\N
130	Fact Check	\N
130	Space	\N
130	Parade	\N
130	Angel Eyes	\N
130	Yacht	\N
130	Je Ne Sais Quoi	\N
130	Love is a beauty	\N
130	Misty	\N
130	Real Life	\N
131	Ay-Yo	\N
131	Faster	\N
131	2 Baddies	\N
131	Time Lapse	\N
131	DJ	\N
131	Crash Landing	\N
131	Designer	\N
131	Gold Dust	\N
131	Black Clouds	\N
131	Playback	\N
131	Skyscraper (摩天樓; 마천루)	\N
131	Tasty (貘)	\N
131	Vitamin	\N
131	LOL (Laugh-Out-Loud)	\N
131	1, 2, 7 (Time Stops)	\N
132	Faster	\N
132	2 Baddies	\N
132	Time Lapse	\N
132	Crash Landing	\N
132	Designer	\N
132	Gold Dust	\N
132	Black Clouds	\N
132	Playback	\N
132	Tasty	\N
132	Vitamin	\N
132	LOL (Laugh-Out-Loud)	\N
132	1, 2, 7 (Time Stops)	\N
133	ICONIC BY MISTAKE	\N
133	ICONIC BY MISTAKE (Clean Edit)	\N
133	ICONIC BY MISTAKE (Instrumental)	\N
134	BOOMPALA (feat. GURU RANDHAWA)	\N
134	BOOMPALA	\N
135	BOOMPALA (feat. SANTOS BRAVOS)	\N
135	BOOMPALA	\N
136	Boompala (Champions Remix)	\N
136	Boompala	\N
137	CELEBRATION (Supergirl Version)	\N
137	CELEBRATION	\N
138	BOOMPALA (KIM CHAEWON Version)	\N
138	BOOMPALA (SAKURA Version)	\N
138	BOOMPALA (HUH YUNJIN Version)	\N
138	BOOMPALA (KAZUHA Version)	\N
138	BOOMPALA (HONG EUNCHAE Version)	\N
139	BOOMPALA (Karaoke Ver.)	\N
139	BOOMPALA (Piano Ver.)	\N
139	BOOMPALA (Sped Up Ver.)	\N
139	BOOMPALA (Slowed + Reverb Ver.)	\N
139	BOOMPALA (Short Ver.)	\N
139	BOOMPALA (Inst.)	\N
140	Pureflow	\N
140	BOOMPALA	\N
140	CELEBRATION	\N
140	Creatures	\N
140	iffy iffy	\N
140	Need Your Company	\N
140	Sonder	\N
140	Saki (feat. Aliyah's Interlude)	\N
140	Irony	\N
140	Trust Exercise	\N
140	Liminal Space	\N
142	Celebration	\N
142	Celebration (Sped Up Ver.)	\N
142	Celebration (Slowed + Reverb Ver.)	\N
142	Celebration (Instrumental)	\N
142	Celebration (Karaoke Ver.)	\N
143	TNT	\N
143	REDRED	\N
143	ACAI	\N
143	YOUNGCREATORCREW	\N
143	Wassup	\N
143	Blue Lips	\N
144	REDRED	\N
145	Mention Me	\N
146	GO!	\N
146	What You Want	\N
146	FaSHioN	\N
146	JoyRide	\N
146	Lullaby	\N
146	What You Want (feat. Teezo Touchdown)	\N
147	CORTIS (코르티스) 'What You Want (feat. Teezo Touchdown)’ Official Visualizer	\N
148	What You Want	\N
149	Sugar Honey Ice Tea	\N
150	MOON	\N
150	CHOOM	\N
150	I LIKE IT	\N
150	LOCKED IN	\N
151	WE GO UP	\N
151	PSYCHO	\N
151	SUPA DUPA LUV	\N
151	WILD	\N
152	DRIP (Remix) (Live)	\N
152	BATTER UP (Live)	\N
152	CLIK CLAK (Live)	\N
152	LIKE THAT (Live)	\N
152	SHEESH (Live)	\N
152	Woke Up In Tokyo (RUKA & ASA) (Live)	\N
152	Love, Maybe (Live)	\N
152	DREAM (Live)	\N
152	BILLIONAIRE (Live)	\N
152	Really Like You (Live)	\N
152	CLAP YOUR HANDS ~ Go Away (2NE1 Cover) (Live)	\N
152	FOREVER (Live)	\N
152	Love In My Heart (Live)	\N
153	HOT SAUCE	\N
154	Ghost	\N
155	CLIK CLAK	\N
155	DRIP	\N
155	Love, Maybe	\N
155	Really Like You	\N
155	BILLIONAIRE	\N
155	Love In My Heart	\N
155	Woke Up In Tokyo (RUKA & ASA)	\N
155	FOREVER	\N
155	BATTER UP (Remix) - Bonus Track	\N
156	BATTER UP JP Ver.	\N
157	FOREVER	\N
158	MONSTERS (Intro)	\N
158	SHEESH	\N
158	LIKE THAT	\N
158	Stuck In The Middle (7 ver.)	\N
158	BATTER UP (7 ver.)	\N
158	DREAM	\N
158	Stuck In The Middle (Remix)	\N
159	Sunday Morning	\N
160	GRWM (Get Ready With Me)	\N
160	It's Me	\N
160	paw, paw!	\N
160	Mamihlapinatapai	\N
160	Love, older you	\N
161	Bubee (Korean Version)	\N
162	Bubee	\N
164	NOT CUTE ANYMORE	\N
164	NOT CUTE ANYMORE (Holiday Party ver.)	\N
164	NOT CUTE ANYMORE (Holiday Night ver.)	\N
164	NOT CUTE ANYMORE (Sped Up ver.)	\N
164	NOT CUTE ANYMORE (Holiday Party Sped up ver.)	\N
164	NOT CUTE ANYMORE (Holiday Night Sped up ver.)	\N
164	NOT CUTE ANYMORE (Instrumental)	\N
165	ALL FOR YOU	\N
165	ALL FOR YOU (Instrumental)	\N
166	NOT CUTE ANYMORE	\N
166	NOT ME	\N
167	Love Smile	\N
167	Love Smile (Instrumental)	\N
168	Heal	\N
168	Growing Pains	\N
168	Baby Blue	\N
168	This!	\N
168	Before You Met Me	\N
168	Glass Half Empty	\N
168	Main Attraction	\N
168	Enemies with Benefits	\N
168	On Our Way	\N
168	Sorry To Myself	\N
169	growing pains	\N
170	Baby Blue	\N
171	N the Front (H.ONE Remix)	\N
172	Do What I Want	\N
172	N The Front	\N
172	Savior	\N
172	Tuscan Leather	\N
172	Catch Me Now	\N
172	Fire & Ice	\N
173	MONSTA X 몬스타엑스 'Do What I Want' MV	\N
174	Beautiful Liar -Japanese ver.-	\N
174	GAMBLER -Japanese ver.-	\N
174	BEASTMODE -Japanese ver.-	\N
174	BEBE -Japanese ver.-	\N
175	Rush Hour (Rerecorded)	\N
175	Autobahn (Rerecorded)	\N
175	Ride with U (Rerecorded)	\N
175	Mercy (Rerecorded)	\N
175	LOVE (Rerecorded)	\N
175	사랑한다 (Rerecorded)	\N
175	Beautiful Liar (Rerecorded)	\N
175	LONE RANGER (Rerecorded)	\N
175	Deny (Rerecorded)	\N
175	괜찮아 (Rerecorded)	\N
176	SWING	\N
177	MONSTA X 몬스타엑스 'Beautiful Liar' MV	\N
177	Daydream	\N
177	춤사위 (Crescendo)	\N
177	LONE RANGER	\N
177	Deny	\N
177	[몬채널][S] MONSTA X 몬스타엑스 - 괜찮아 (Self-cam ver.)	\N
178	Mono (Feat. Skaiwater)	\N
178	Gimme Dat Love	\N
178	Morning	\N
178	Crow	\N
178	Love Is Pain	\N
179	Crow	\N
180	Hide and Seek	\N
181	Mono (Feat. skaiwater)	\N
182	GAME	\N
183	Where Do We Go	\N
183	Invincible	\N
183	Farewell to the World	\N
183	Fate (Japanese ver.)	\N
183	Queencard (Japanese ver.)	\N
184	[Solo Leveling:ARISE x i-dle] “ARISE”🎵 Music Video Short Film Version Revealed!	\N
184	ARISE (Instrumental)	\N
185	Girlfriend	\N
185	Good Thing	\N
185	Love Tease	\N
185	Chain	\N
185	Unstoppable	\N
185	If You Want	\N
186	LATATA (i-dle ver.)	\N
186	HANN (Alone) (i-dle ver.)	\N
186	Senorita (i-dle ver.)	\N
186	Uh-Oh (i-dle ver.)	\N
186	i’M THE TREND (i-dle ver.)	\N
186	Oh my god (i-dle ver.)	\N
186	LION (i-dle ver.)	\N
186	DUMDi DUMDi (i-dle ver.)	\N
186	HWAA (i-dle ver.)	\N
187	Klaxon	\N
187	Bloom	\N
187	Last Forever	\N
187	Neverland	\N
188	Atmos	\N
188	HOURS	\N
188	Possibility	\N
188	Anti Believer	\N
188	Still Raining	\N
188	Thousand Miles Away	\N
189	Poet | Artist	\N
189	Starlight	\N
190	HARD	\N
190	JUICE	\N
190	10X	\N
190	Satellite	\N
190	Identity	\N
190	The Feeling	\N
190	Like It	\N
190	Sweet Misery	\N
190	Insomnia	\N
190	Gravity	\N
191	SHINee シャイニー 'SUPERSTAR' MV	\N
191	Closer	\N
191	SHINee 샤이니 'Don't Call Me' MV	\N
191	SHINee 샤이니 'Atlantis' MV	\N
191	Seasons	\N
192	Atlantis	\N
192	CØDE	\N
192	Don't Call Me	\N
192	Area	\N
192	Heart Attack	\N
192	Marry You	\N
192	Days and Years	\N
192	I Really Want You	\N
192	Kiss Kiss	\N
192	Attention	\N
192	Body Rhythm	\N
192	Kind	\N
193	SHINee 샤이니 'Don't Call Me (Fox Stevenson Remix)' MV	\N
193	Don't Call Me (ESAI Remix)	\N
194	Don't Call Me	\N
194	Heart Attack	\N
194	Marry You	\N
194	CØDE	\N
194	I Really Want You	\N
194	Kiss Kiss	\N
194	Body Rhythm	\N
194	Attention	\N
194	Kind	\N
195	All Day All Night	\N
195	Countless	\N
195	Good Evening	\N
195	Chemistry	\N
195	Electric	\N
195	Who Waits For Love	\N
195	Our Page	\N
195	I Say	\N
195	Retro	\N
195	Drive	\N
195	I Want You	\N
195	Undercover	\N
195	JUMP	\N
195	Tonight	\N
195	You & I	\N
195	Lock You Down - Special Track	\N
196	LUCID DREAM (Taku Takahashi Remix)	\N
197	Lucid Dream	\N
197	Fashion	\N
197	Jigsaw	\N
197	Rebel Heart (Japanese Ver.)	\N
197	Attitude (Japanese Ver.)	\N
197	Thank U (Japanese ver.)	\N
198	Fashion	\N
199	BLACKHOLE	\N
199	BANG BANG	\N
199	Hush	\N
199	Stuck In Your Head	\N
199	Fireworks	\N
199	HOT COFFEE	\N
199	8 (JANG WONYOUNG Solo)	\N
199	Odd (GAEUL Solo)	\N
199	Super ICY (LEESEO Solo)	\N
199	Unreal (LIZ Solo)	\N
199	In Your Heart (REI Solo)	\N
199	Force (AN YUJIN Solo)	\N
200	BANG BANG	\N
201	XOXZ	\N
201	Wild Bird	\N
201	Dear, My Feelings	\N
201	GOTCHA (Baddest Eros)	\N
201	삐빅 (♥beats)	\N
201	Midnight Kiss	\N
202	Be Alright	\N
202	DARE ME	\N
202	Accendio -Japanese version-	\N
202	Blue Heart -Japanese version-	\N
202	WOW -Japanese version-	\N
203	DARE ME	\N
204	REBEL HEART	\N
204	FLU	\N
204	You Wanna Cry	\N
204	Thank U	\N
204	ATTITUDE	\N
204	TKO	\N
205	REBEL HEART	\N
206	FOREVER 1 (Matisse & Sadko Remix)	\N
206	FOREVER 1 (Aiobahn Remix)	\N
206	FOREVER 1 (Mar Vista Remix)	\N
206	FOREVER 1 (Matisse & Sadko Remix, Extended Version)	\N
206	FOREVER 1 (Aiobahn Remix, Extended Version)	\N
206	FOREVER 1 (Mar Vista Remix, Extended Version)	\N
207	FOREVER 1	\N
207	You Better Run	\N
207	Villain	\N
207	Lucky Like That	\N
207	Closer	\N
207	Seventeen	\N
207	Paper Plane	\N
207	Freedom	\N
207	Mood Lamp	\N
207	Summer Night	\N
208	Girls Are Back	\N
208	All Night	\N
208	Holiday	\N
208	Fan	\N
208	Only One	\N
208	One Last Time	\N
208	Sweet Talk	\N
208	Love is Bitter	\N
208	It's You	\N
208	Light Up The Sky	\N
209	Sailing (0805)	\N
209	Sailing (0805) (Instrumental)	\N
210	Party	\N
210	Lion Heart	\N
210	You Think	\N
210	Check	\N
210	One Afternoon	\N
210	Show Girls	\N
210	Fire Alarm	\N
210	Talk Talk	\N
210	Green Light	\N
210	Paradise	\N
210	Sign	\N
210	Bump It	\N
211	PARTY	\N
211	Check	\N
211	PARTY (Instrumental)	\N
212	Catch Me If You Can (Korean Version)	\N
212	Girls (Korean Version)	\N
213	Mr. Mr.	\N
213	Goodbye	\N
213	Europa	\N
213	Wait a Minute	\N
213	Back Hug	\N
213	Soul	\N
214	Supernatural	\N
214	Right Now	\N
214	Supernatural (Instrumental)	\N
214	Right Now (Instrumental)	\N
215	How Sweet	\N
215	Bubble Gum	\N
215	How Sweet (Instrumental)	\N
215	Bubble Gum (Instrumental)	\N
216	Ditto – 250 Remix	\N
216	OMG – FRNK Remix	\N
216	Attention – 250 Remix	\N
216	Hype Boy – 250 Remix	\N
216	Cookie – FRNK Remix	\N
216	NewJeans (뉴진스) 'Hurt (250 Remix)' Special Video	\N
216	Ditto – 250 Remix (Instrumental)	\N
216	OMG – FRNK Remix (Instrumental)	\N
216	Attention – 250 Remix (Instrumental)	\N
216	Hype Boy – 250 Remix (Instrumental)	\N
216	Cookie – FRNK Remix (Instrumental)	\N
216	Hurt – 250 Remix (Instrumental)	\N
217	Our Night is more beautiful than your Day	\N
217	Our Night is more beautiful than your Day (Inst.)	\N
218	GODS	\N
219	Beautiful Restriction	\N
220	New Jeans	\N
220	Super Shy	\N
220	ETA	\N
220	Cool With You	\N
220	Get Up	\N
220	ASAP	\N
221	New Jeans	\N
221	Super Shy	\N
222	Zero (J.I.D Remix)	\N
223	Be Who You Are (Real Magic) (feat. JID, NewJeans & Camilo)	\N
224	Spring Breeze, Again	\N
225	WE WANNA GO	\N
226	Beautiful (Part.3)	\N
227	Light	\N
227	Kangaroo (Prod. ZICO)	\N
227	Forever And A Day (Prod. NELL)	\N
227	Sandglass (Prod. Heize)	\N
227	11 (Eleven) (Prod. Dynamicduo)	\N
228	GOLD	\N
228	I PROMISE YOU (I.P.U.)	\N
228	BOOMERANG	\N
228	WE ARE	\N
228	DAY BY DAY	\N
228	I'LL REMEMBER	\N
228	I PROMISE YOU (Propose Ver.)	\N
229	Nothing Without You (Intro.)	\N
229	Beautiful	\N
229	Wanna	\N
229	Twilight	\N
229	Burn it Up (Prequel Remix)	\N
229	Energetic (Prequel Remix)	\N
229	Wanna Be (My Baby)	\N
229	Energetic	\N
229	Burn It Up	\N
229	To be One (Outro)	\N
230	To be one (Intro)	\N
230	Burn it Up	\N
230	Energetic	\N
230	Wanna Be (My Baby)	\N
230	Always (Acoustic Ver.)	\N
231	Baggy Jeans	\N
231	Call D	\N
231	PADO	\N
231	Interlude: Oasis	\N
231	The BAT	\N
231	Alley Oop	\N
231	That’s Not Fair	\N
231	Kangaroo	\N
231	Not Your Fault	\N
231	Golden Age	\N
232	New Axis	\N
232	Universe (Let's Play Ball)	\N
232	Earthquake	\N
232	OK!	\N
232	Birthday Party	\N
232	Know Now	\N
232	Dreaming	\N
232	Round&Round	\N
232	Miracle	\N
232	Vroom	\N
232	Sweet Dream	\N
232	Good Night	\N
232	Beautiful	\N
233	Make a Wish (Birthday Song) [Wuki Remix]	\N
233	90's Love (SQUAR Remix)	\N
234	Resonance	\N
235	90's Love	\N
235	Misfit (NCT U)	\N
235	Raise The Roof	\N
235	Volcano	\N
235	Light Bulb	\N
235	Dancing In The Rain	\N
235	My Everything	\N
235	Interlude: Past To Present	\N
235	Make A Wish (Birthday Song)	\N
235	Déjà Vu	\N
235	Nectar	\N
235	Music, Dance	\N
235	Faded In My Last Song	\N
235	From Home	\N
235	From Home (Korean Ver.)	\N
235	Make a Wish (Birthday Song) (English Ver.)	\N
235	Interlude: Present to Future	\N
235	Work It	\N
235	All About You	\N
235	I.O.U.	\N
235	Outro: Dream Routine	\N
236	Make a Wish (Birthday Song)	\N
236	Misfit	\N
236	Volcano	\N
236	Light Bulb	\N
236	Dancing in the Rain	\N
236	Interlude: Past to Present	\N
236	Déjà Vu	\N
236	Nectar	\N
236	Music, Dance	\N
236	Faded In My Last Song	\N
236	From Home	\N
236	From Home (Korean Ver.)	\N
236	Make a Wish (Birthday Song) (English Ver.)	\N
237	Timeless	\N
237	INTRO: Neo Got My Back	\N
237	BOSS	\N
237	Baby Don't Stop	\N
237	GO	\N
237	TOUCH	\N
237	YESTODAY	\N
237	Black on Black	\N
237	The 7th Sense	\N
237	Without You	\N
237	Without You (Chinese Ver.)	\N
237	Dream in a Dream (Ten Solo)	\N
237	OUTRO: VISION	\N
237	YESTODAY - Extended Version	\N
238	Pinky Up	\N
240	Pinky Up	\N
240	Pinky Up (Club Remix)	\N
240	Pinky Up (Sunset Remix)	\N
240	Pinky Up (Katwalk Remix)	\N
240	Pinky Up (Techno Remix)	\N
241	PINKY UP	\N
242	Internet Girl	\N
243	M.I.A (VALORANT Game Changers Version)	\N
244	Gnarly - (Extended Version)	\N
244	Gabriela - (JULiA LEWiS Reggaeton Remix)	\N
244	Gabriela - (Extended Version)	\N
244	Gabriela - (Sped Up Version)	\N
244	Gameboy - (JULiA LEWiS Acoustic Remix)	\N
244	Gameboy - (Extended Version)	\N
244	Gameboy - (Sped Up Version)	\N
245	Gabriela (Young Miko Remix)	\N
246	Monster High Fright Song ft. KATSEYE	\N
246	Monster High Fright Song ft. KATSEYE (Animated M/V)	\N
247	Be My Love	\N
247	Be My Love (Inst.)	\N
248	Paper Cuts	\N
249	CBX	\N
249	Ka-CHING!	\N
249	Horololo	\N
249	Girl Problems	\N
249	Shake	\N
249	Off The Wall	\N
249	Ringa Ringa Ring	\N
249	Gentleman	\N
249	Watch Out	\N
249	Cry	\N
249	In This World	\N
250	Beautiful World	\N
251	Monday Blues	\N
251	Blooming Day	\N
251	Sweet Dreams	\N
251	Thursday	\N
251	Vroom Vroom	\N
251	Playdate	\N
251	Lazy	\N
252	Someone Like You	\N
252	Someone Like You (Inst.)	\N
254	It's Running Time!	\N
255	Girl Problems	\N
255	Ka-CHING!	\N
255	Hey Mama!	\N
255	Tornado Spiral	\N
255	Miss You	\N
255	Diamond Crystal	\N
255	KING and QUEEN	\N
256	CRUSH U (with Yoonsang)	\N
257	Beat It Up	\N
257	Rush	\N
257	Cold Coffee	\N
257	Butterflies	\N
257	Tempo	\N
257	TRICKY	\N
258	BTTF	\N
258	CHILLER	\N
258	I LIKE IT	\N
258	DREAM TEAM	\N
258	Interlude : Back to Our Paradise	\N
258	’Bout You	\N
258	That Summer	\N
258	Miss Me	\N
258	Beautiful Sailing	\N
259	INTRO : DREAMSCAPE	\N
259	When I’m With You	\N
259	Flying Kiss	\N
259	i hate fruits	\N
259	No Escape	\N
259	Best of Me	\N
259	YOU	\N
259	Heavenly	\N
259	Night Poem	\N
259	Off The Wall	\N
259	Rains in Heaven	\N
260	Hello Future - KENZIE RE:WORKS	\N
261	Rains in Heaven	\N
262	Moonlight	\N
262	Stupid Cupid	\N
263	Smoothie	\N
263	icantfeelanything	\N
263	BOX	\N
263	Carat Cake	\N
263	UNKNOWN	\N
263	Breathing	\N
264	NCT DREAM, JVKE 'Broken Melodies (JVKE Remix)' (Official Audio)	\N
264	NCT DREAM 엔시티 드림 'Broken Melodies' MV	\N
265	Crescendo	\N
265	Heavy Serenade	\N
265	IDESERVEIT	\N
265	Different Girl	\N
265	Superior	\N
265	LOUD	\N
266	TIC TIC (feat. Pabllo Vittar)	\N
267	[제4차 사랑혁명] 엔믹스(NMIXX) 배이 - Up&Down MV ㅣOSTㅣ웨이브 오리지널	\N
267	Up & Down (Inst.)	\N
268	MEXE (feat. Cobrah & NMIXX)	\N
268	Mexe (feat. NMIXX) (Miss Tacacá & LOFIHOUSEBOY Remix)	\N
268	MEXE	\N
269	NMIXX(엔믹스) “Blue Valentine” M/V	\N
269	Blue Valentine (English Ver.)	\N
269	Blue Valentine (A Cappella Ver.)	\N
269	Blue Valentine (Sped Up Ver.)	\N
269	Blue Valentine (Inst.)	\N
270	Blue Valentine	\N
270	SPINNIN’ ON IT	\N
270	Phoenix	\N
270	Reality Hurts	\N
270	RICO	\N
270	Game Face	\N
270	PODIUM	\N
270	Crush On You	\N
270	ADORE U	\N
270	Shape of Love	\N
270	O.O Part 1 (Baila)	\N
270	O.O Part 2 (Superhero)	\N
272	릴리 (NMIXX) & 지우 (NMIXX) & 규진 (NMIXX) - Ridin′ (Prod. THE HUB)｜ WSWF｜Lyric Video｜Stone Music Playlist	\N
273	KNOW ABOUT ME	\N
273	Slingshot	\N
273	Golden Recipe	\N
273	Papillon	\N
273	Ocean	\N
273	NMIXX(엔믹스) “High Horse” (Official Audio)	\N
274	Lemon Tang	\N
274	15-LOVE	\N
274	Baby Steps	\N
274	heart emoji (♡)	\N
274	Secret Recipe	\N
274	RUDE!	\N
275	RUDE! (Silly Silky Remix)(feat.Silly Silky)	\N
275	RUDE! (yunji Remix)	\N
275	RUDE!	\N
276	Rude! (Japanese Ver.)	\N
277	RUDE!	\N
278	The Chase (0to Remix)	\N
278	The Chase (YOHAN Remix)	\N
278	The Chase (SONGUN Remix)	\N
278	The Chase (Arti & Suchan Kim Remix)	\N
278	The Chase (SOR Remix)	\N
279	FOCUS (Jaebin Remix)	\N
279	FOCUS (DJ Seinfeld Remix)	\N
279	FOCUS (Young Franco Remix)	\N
279	FOCUS (sooyeon Remix)	\N
279	Hearts2Hearts 하츠투하츠 'FOCUS' MV	\N
280	FOCUS	\N
280	Apple Pie	\N
280	Pretty Please	\N
280	Flutter	\N
280	Blue Moon	\N
281	Pretty Please	\N
282	STYLE	\N
283	My Christmas Sweet Love	\N
283	Jazz Bar (Carol ver.)	\N
283	Wonderland (Carol ver.)	\N
284	Intro : 7' Dreamcatcher	\N
284	JUSTICE	\N
284	STΦMP!	\N
284	2 Rings	\N
284	Fireflies	\N
285	Lullaby (2024 Concert Ver.)	\N
285	The curse of the Spider (2024 Concert Ver.)	\N
286	Intro : This My Fashion	\N
286	OOTD	\N
286	Rising	\N
286	Shatter	\N
286	We Are Young	\N
287	Dreamcatcher(드림캐쳐) 'BONVOYAGE (Farewell Ver.)' MV (Lyrics)	\N
288	Intro : From us	\N
288	BONVOYAGE	\N
288	DEMIAN	\N
288	Propose	\N
288	To. You	\N
289	REASON	\N
289	REASON (Inst.)	\N
290	Intro : Chaotical X	\N
290	VISION	\N
290	Fairytale	\N
290	Some Love	\N
290	Rainy Day	\N
290	Outro : Mother Nature	\N
291	Intro : Save us	\N
291	Locked Inside A Door	\N
291	MAISON	\N
291	Starlight	\N
291	Together	\N
291	Always	\N
291	Skit : The seven doors	\N
291	Cherry (Real Miracle) (JI U SOLO)	\N
291	No Dot (SU A SOLO)	\N
291	Entrancing (SIYEON SOLO)	\N
291	Winter (HANDONG SOLO)	\N
291	For (YOOHYEON SOLO)	\N
291	Beauty Full (DAMI SOLO)	\N
291	Playground (GAHYEON SOLO)	\N
292	Intro	\N
292	BEcause	\N
292	Airplane	\N
292	Whistle	\N
292	Alldaylong	\N
292	A Heart of Sunflower	\N
294	UNIQUE	\N
294	Pandemonium	\N
294	L.O.Y.L.	\N
294	Wednesday Girl	\N
294	Triple 7	\N
294	ICE (VVS)	\N
295	EX	\N
295	Dancing Queen	\N
295	Stupid Brain	\N
295	Night Of My Life	\N
295	EX (Spanish ver.)	\N
296	DUH!	\N
296	Pretty Boy	\N
296	Murmur	\N
296	Flashy	\N
296	Work	\N
296	Over And Over	\N
297	R.O.P (Reign of Peace) (Prod. Czaer)	\N
297	R.O.P (Reign of Peace) (Instrumental) (Prod. Czaer)	\N
298	SAD SONG	\N
298	It's Alright	\N
298	Last Call	\N
298	Welcome To	\N
298	All You	\N
298	WASP	\N
298	SAD SONG (English Ver.)	\N
299	Killin' It (English Version) (때깔 (Killin' It) (English Version))	\N
300	Fall In Love Again (Prod. by C. “Tricky” Stewart & Believve)	\N
301	JUMP (English Version)	\N
302	NCT U 엔시티 유 'Do It (Let’s Play)' NCT ZONE OST Making Video	\N
303	Marine Turtle	\N
303	Marine Turtle (Korean Ver.)	\N
303	Marine Turtle (Instrumental)	\N
304	N.Y.C.T	\N
304	N.Y.C.T (Inst.)	\N
305	Rain Day	\N
305	Rain Day (Inst.)	\N
306	coNEXTion (Age of Light)	\N
307	[MV] NCT U _ Maniac (Sung by DOYOUNG(도영),HAECHAN(해찬)) (Prod. RYAN JHUN(라이언전))	\N
308	Coming Home	\N
308	Coming Home (Inst.)	\N
309	LUMINOUS	\N
309	SICK LOVE	\N
309	Hi High (Japanese Version)	\N
310	The Journey	\N
310	Flip That	\N
310	Need U	\N
310	POSE	\N
310	Pale Blue Dot	\N
310	Playback	\N
311	JINAON (Epilogue)(feat.Hyolyn,Yuna,Seola,Eunha,HeeJin,Yeseo)	\N
312	Waka Boom (My Way)(feat.Hyolyn,Lee Young-ji)	\N
312	AURA(feat.WJSN)	\N
312	THE GIRLS (Can't turn me down)(feat.Kep1er)	\N
312	Red Sun!(feat.VIVIZ)	\N
312	POSE(feat.LOONA)	\N
312	Whistle(feat.BB GIRLS)	\N
313	Butterfly(feat.LOONA)	\N
313	Red Sun (Remix)(feat.BB GIRLS)	\N
313	See Sea, BAE(feat.Hyolyn)	\N
314	Purr(feat.SinB,Umji,Xiaoting,Dayeon,Hikaru)	\N
314	KA-BOOM!(feat.Hyolyn,Eunseo,Yeoreum)	\N
314	Tell me now(feat.Eunji,Yves,HeeJin,Choerry,HyeJu)	\N
315	Don't Go (Queendom2 Ver.)(feat.JinSoul,HaSeul,Kim Lip,Chuu,Chaehyun,Youngeun)	\N
316	NAVILLERA(feat.WJSN)	\N
316	SHAKE IT(feat.LOONA)	\N
316	MVSK (Remix)(feat.BB GIRLS)	\N
317	WA DA DA (QUEENDOM2 Ver.)(feat.Kep1er)	\N
317	Chi Mat Ba Ram+Rollin' (Remix)(feat.BB GIRLS)	\N
317	As You Wish(feat.WJSN)	\N
317	PTT (Paint The Town)(feat.LOONA)	\N
318	Yummy-Yummy	\N
318	Yummy-Yummy - Instrumental	\N
319	Blooming (Intro)	\N
319	4 Flowers	\N
319	4 Flowers (Acoustic Remix)	\N
319	4 Flowers (Latin Remix)	\N
319	4 Flowers (Inst.)	\N
320	MMM Simile (Live ver.)	\N
320	MMM Simile (Inst.)	\N
321	Where Are We Now -Japanese ver.-	\N
321	Another Day (내일의 너, 오늘의 나 (Another Day))	\N
321	A Memory for Life (애써 (A Memory for Life))	\N
321	Destiny Part.2 (우린 결국 다시 만날 운명이었지 Part.2 (Destiny Part.2))	\N
321	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
321	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
321	MAMAMOO「mumumumuch -Japanese ver.-」 Music Video	\N
321	Strange Day	\N
322	Paint Me (Orchestra ver.) (칠해줘 (Paint Me) (Orchestra ver.))	\N
322	Starry Night (Orchestra ver.) (별이 빛나는 밤 (Starry Night) (Orchestra ver.))	\N
322	gogobebe (Rock ver.) (고고베베 (gogobebe) (Rock ver.))	\N
322	Egotistic (Blistering sun ver.) (너나 해 (Egotistic) (Blistering sun ver.))	\N
322	You’re the best 2021 (넌 is 뭔들 2021 (You’re the best 2021))	\N
322	I Miss You 2021 (I Miss You 2021)	\N
322	Happier than Ever (분명 우린 그땐 좋았었어 (Happier than Ever))	\N
322	HeeHeeHaHeHo Part.2 (히히하헤호 Part.2 (HeeHeeHaHeHo Part.2))	\N
322	Words Don't Come Easy 2021 (우리끼리 2021 (Words Don't Come Easy 2021))	\N
322	Piano Man 2021 (Piano Man 2021)	\N
322	AHH OOP 2021 (AHH OOP 2021)	\N
322	Decalcomanie 2021 (Decalcomanie 2021)	\N
322	AYA (Traditional ver.) (AYA (Traditional ver.))	\N
322	HIP (Remix ver.) (HIP (Remix ver.))	\N
322	A little bit 2021 (따끔 2021 (A little bit 2021))	\N
322	Wind flower (Dramatic ver.) (Wind flower (Dramatic ver.))	\N
322	Um Oh Ah Yeh 2021 (음오아예 2021 (Um Oh Ah Yeh 2021))	\N
322	Don’t Be Happy 2021 (행복하지마 2021 (Don’t Be Happy 2021))	\N
322	Peppermint Chocolate (MMM ver.) (썸남썸녀 (Peppermint Chocolate) (MMM ver.))	\N
322	[MV] 마마무 (MAMAMOO) - 하늘 땅 바다만큼 (mumumumuch)	\N
322	Destiny (Extended ver.) (우린 결국 다시 만날 운명이었지 (Destiny) (Extended ver.))	\N
322	Mr. Ambiguous 2021 (Mr.애매모호 2021 (Mr. Ambiguous 2021))	\N
322	Yes I am (Funk boost ver.) (나로 말할 것 같으면 (Yes I am) (Funk boost ver.))	\N
323	Where Are We Now	\N
323	Another Day	\N
323	A Memory for Life	\N
323	Destiny Part.2	\N
324	MAMAMOO - WANNA BE MYSELF	\N
324	[MV] 마마무 (MAMAMOO) - 딩가딩가 (Dingga)	\N
324	MAMAMOO - AYA	\N
324	MAMAMOO - Travel	\N
324	MAMAMOO - Chuck	\N
324	MAMAMOO - Diamond	\N
324	MAMAMOO - Good Night	\N
324	MAMAMOO - AYA (Japanese Ver.)	\N
324	MAMAMOO - Dingga (Japanese Ver.)	\N
324	MAMAMOO - Just Believe in Love	\N
325	Travel	\N
325	Dingga	\N
325	AYA	\N
325	Chuck	\N
325	Diamond	\N
325	Good Night	\N
326	Dingga	\N
326	Dingga (Inst.)	\N
327	WANNA BE MYSELF	\N
327	WANNA BE MYSELF (Inst.)	\N
328	Season of Memories	\N
328	Always	\N
329	GFRIEND (여자친구) '우리의 다정한 계절 속에' OFFICIAL MV	\N
330	MAGO	\N
330	Love Spell	\N
330	Three Of Cups	\N
330	GRWM	\N
330	Secret Diary	\N
330	Better Me	\N
330	Night Drive	\N
330	GFRIEND - Apple	\N
330	GFRIEND - Crossroads	\N
330	GFRIEND - Labyrinth	\N
330	GFRIEND - Wheel of the year	\N
331	Apple	\N
331	Eye of The Storm	\N
331	Room of Mirrors	\N
331	Tarot Cards	\N
331	Crème Brulée	\N
331	Stairs In The North	\N
332	Labyrinth	\N
332	GFRIEND (여자친구) '교차로 (Crossroads)' Official M/V	\N
332	Here We Are	\N
332	지금 만나러 갑니다 (Eclipse)	\N
332	Dreamcatcher	\N
332	From Me	\N
333	Apple	\N
333	Eye of The Storm	\N
333	Room of Mirrors	\N
333	Tarot Cards	\N
333	Crème Brûlée	\N
333	Stairs in the North	\N
334	Labyrinth	\N
334	Crossroads	\N
334	Here We Are	\N
334	Eclipse	\N
334	Dreamcatcher	\N
334	From Me	\N
335	Fallin' Light	\N
335	Memoria	\N
335	FLOWER	\N
335	SUNRISE -JP ver.-	\N
336	Fever	\N
336	Mr. Blue	\N
336	Smile	\N
336	Wish	\N
336	Paradise	\N
336	Hope	\N
336	FLOWER - Korean Version	\N
336	Fever - Instrumental	\N
337	GFRIEND - Cheers (ZZAN)	\N
338	Memory of the Moon	\N
339	Twilight	\N
340	Circles	\N
341	U&Iverse	\N
342	Candy Sugar Pop	\N
342	Something Something	\N
342	More	\N
342	Light the sky	\N
342	Story	\N
342	All Day	\N
342	First Love	\N
342	Let's go ride	\N
342	S#1.	\N
342	24 Hours	\N
342	Like stars	\N
343	Ichiban Suki na Hito ni Sayonara wo Iou	\N
343	Ichiban Suki na Hito ni Sayonara wo Iou (Inst.)	\N
344	ALIVE	\N
345	All Good-JP Ver.-	\N
346	After Midnight	\N
346	Footprint	\N
346	Waterfall	\N
346	Sunset Sky	\N
346	MY ZONE	\N
346	Don’t Worry	\N
347	Dear my universe	\N
347	Butterfly Effect	\N
347	ONE	\N
347	Someone Else	\N
347	SNS	\N
347	All Good	\N
347	All Stars	\N
347	Our spring	\N
347	Stardust	\N
347	gemini	\N
348	Still Life	\N
349	Flower Road	\N
350	FXXK IT	\N
350	LAST DANCE	\N
350	GIRL FRIEND	\N
350	LET'S NOT FALL IN LOVE	\N
350	LOSER	\N
350	BAE BAE	\N
350	BANG BANG BANG	\N
350	SOBER	\N
350	IF YOU	\N
350	ZUTTER (GD&T.O.P)	\N
350	WE LIKE 2 PARTY	\N
352	ZUTTER (GD&T.O.P)	\N
352	LET'S NOT FALL IN LOVE	\N
353	BANG BANG BANG	\N
353	We like 2 party	\N
354	LOSER	\N
354	BAE BAE	\N
355	Still Alive	\N
355	MONSTER	\N
355	Feeling	\N
355	FANTASTIC BABY	\N
355	BAD BOY	\N
355	BLUE	\N
355	Bingle Bingle	\N
355	Ego	\N
355	Love Dust	\N
355	Monster (Inst.)	\N
356	Intro (Alive)	\N
356	BLUE	\N
356	Love Dust	\N
356	BAD BOY	\N
356	Ain't No Fun	\N
356	FANTASTIC BABY	\N
356	Wings (Daesung Solo)	\N
357	06070	\N
357	VIRAL	\N
357	ddok ddok ddok	\N
357	ADIOS!	\N
357	Upside Down	\N
357	DIVE	\N
357	Forever You	\N
357	I Wonder	\N
358	KNOCK KNOCK KNOCK	\N
359	No Doubt	\N
359	No Doubt (Inst.)	\N
360	Earth, Wind & Fire (Buldak Hotter Than My EX Ver.)	\N
361	Nice Guy (Live Ver.)	\N
361	Serenade (Live Ver.)	\N
361	123-78 (Live Ver.)	\N
361	OUR (Live Ver.)	\N
361	l i f e i s c o o l (Live Ver.)	\N
361	But I Like You (Live Ver.)	\N
361	One and Only (Live Ver.)	\N
361	Step By Step (Live Ver.)	\N
361	IF I SAY, I LOVE YOU (Live Ver.)	\N
361	I Feel Good (Live Ver.)	\N
361	Dangerous (Live Ver.)	\N
361	But Sometimes (Live Ver.)	\N
361	Crying (Live Ver.)	\N
361	Dear. My Darling (Live Ver.)	\N
361	Gonna Be A Rock (Live Ver.)	\N
361	Earth, Wind & Fire (Live Ver.)	\N
362	SAY CHEESE!	\N
363	Live In Paris	\N
363	Hollywood Action	\N
363	JAM!	\N
363	Bathroom	\N
363	As Time Goes By	\N
364	Count To Love	\N
364	I Feel Good (Japanese Version)	\N
364	Nice Guy (Japanese Version)	\N
364	Dangerous (Japanese Version)	\N
365	123-78	\N
365	I Feel Good	\N
365	Step By Step	\N
365	Is That True?	\N
365	Next Mistake	\N
365	IF I SAY, I LOVE YOU	\N
365	I Feel Good (English Ver.)	\N
366	Never Loved This Way Before	\N
366	Never Loved This Way Before (Instrumental)	\N
367	4SHO 4SHO	\N
367	YEAH YEAH!	\N
367	NO HI, NO HEY	\N
367	RUN IT UP	\N
367	GGUKBONG	\N
367	MOYA	\N
367	THE PURGE 4SHOMIX	\N
367	PUBLIC ENEMY 4SHOMIX(feat.DJ Wegun)	\N
368	Good Girls (Louis Solo)	\N
368	Boo Thang (Woojin Solo)	\N
368	Summer Eyes (Ohyul Solo)	\N
368	For Us (Ryul Solo)	\N
368	Vanilla Days	\N
369	Are You Ready	\N
369	Trust Myself	\N
369	Thinking	\N
369	All Good	\N
369	Ejeh	\N
369	Next 2 U	\N
369	My Side	\N
369	Next 2 U (Sped Up)	\N
369	Next 2 U (Carol Remix)	\N
369	Next 2 U (Carol Remix) (Sped Up)	\N
370	Saucin’	\N
370	Moonwalkin	\N
370	FaceTime	\N
370	Backseat	\N
370	Never Let Go	\N
371	Saucin’	\N
372	iKON - "PANORAMA" MV	\N
372	T.T.M	\N
373	U	\N
373	Tantara	\N
373	RUM PUM PUM	\N
373	Like a Movie	\N
373	Driving Slowly	\N
373	Never Forget You	\N
373	All The Way Here	\N
373	FIGHTING - SONG SOLO	\N
373	Kiss Me - DK SOLO	\N
373	Want You Back - JU-NE SOLO	\N
374	BUT YOU	\N
374	DRAGON	\N
374	FOR REAL?	\N
374	GOLD	\N
374	NAME	\N
375	At ease	\N
376	Why Why Why	\N
377	Ah Yeah	\N
377	Dive	\N
377	All The World	\N
377	Holding On	\N
377	Flower	\N
378	I'm OK	\N
379	GOODBYE ROAD	\N
379	Don't Let Me Know	\N
379	ADORE YOU	\N
379	PERFECT	\N
380	KILLING ME	\N
380	Freedom	\N
380	Only You	\N
380	Cocktail	\N
380	Just For You	\N
381	Rubber Band	\N
382	THE RULES	\N
382	SERVE	\N
382	Extancy (Wumuti & Rui)	\N
382	BACK 2 BACK	\N
382	HIPS (Hyun & Haru)	\N
382	Masterpiece	\N
382	SERVE (Inst.)	\N
383	Rizz	\N
383	Scent	\N
383	Dirty Baby	\N
383	Biii:-P	\N
383	Kiss and say goodbye	\N
383	Drip Drip	\N
384	1&Only	\N
384	1 of LOV	\N
384	BIZNESS	\N
384	1 & Only (Instrumental)	\N
384	1 of LOV (Instrumental)	\N
384	BIZNESS (Instrumental)	\N
385	I’mma Be	\N
385	I'mma Be (88 Techno Remix by dxp)	\N
385	I'mma Be (Dark House Remix by dxp)	\N
385	I'mma Be (Backing Track)	\N
387	Intro.	\N
387	TOP 5	\N
387	V For Vision	\N
387	Customize	\N
387	Exotic	\N
387	Changes	\N
387	Zero To Hundred	\N
388	Running to Future	\N
388	ROSES	\N
388	LOVEPOCALYPSE	\N
389	ROSES	\N
390	Running to Future	\N
391	ICONIK (Japanese ver.)	\N
391	SLAM DUNK (Japanese ver.)	\N
391	BLUE (Japanese ver.)	\N
392	ICONIK	\N
392	SLAM DUNK	\N
392	Lovesick Game	\N
392	Goosebumps	\N
392	Dumb	\N
392	NOW OR NEVER (Korean ver.)	\N
392	EXTRA(feat.Sung Han Bin,Seok Matthew,Kim Gyu Vin,Park Gun Wook,Han Yu Jin)	\N
392	Long Way Back(feat.Kim Ji Woong,Zhang Hao,Kim Tae Rae,Ricky)	\N
392	Star Eyes	\N
392	I Know U Know	\N
393	D-DAY (ZEROBASEONE)	\N
393	UPSIDE DOWN (YOUNG POSSE)	\N
393	Goodbye (Choo Young-woo)	\N
393	Better with you (Colde)	\N
393	When we meet again (Miyeon)	\N
393	Close to You  (CHEEZE)	\N
393	Burden (Jo Hyun-ah)	\N
393	D-DAY (Instrumental)	\N
393	UPSIDE DOWN (Instrumental)	\N
393	Goodbye (Instrumental)	\N
393	Better with you (Instrumental)	\N
393	When we meet again (Instrumental)	\N
393	Close To You (Instrumental)	\N
393	Burden (Instrumental)	\N
394	SLAM DUNK	\N
395	D-DAY	\N
395	D-DAY (Inst.)	\N
396	ZERO:ATTITUDE	\N
397	D-D-DANCE	\N
398	Mis-en-Scène	\N
398	Panorama	\N
398	Island	\N
398	Sequence	\N
398	O Sole Mio	\N
398	느린여행 Slow Journey	\N
399	Beware	\N
399	Vampire	\N
399	好きと言わせたい Suki to Iwasetai	\N
399	Waiting	\N
399	Buenos Aires	\N
399	好きになっちゃうだろう? Suki ni Nacchaudarou? (IZ*ONE Version)	\N
399	Yummy Summer(feat.Sakura,Kim Chaewon,Minju,Yujin)	\N
399	La Vie en Rose (Japanese Version)	\N
399	Violeta (Japanese Version)	\N
399	FIESTA (Japanese Version)	\N
399	夢を見ている間 Yume wo Miteiru Aida (Japanese Version)	\N
399	どうすればいい? Dousurebaii?(feat.Kwon Eunbi,Yena,Hitomi,Wonyoung)	\N
399	Shy Boy(feat.Kang Hyewon,Lee Chae Yeon,Nako,Jo Yuri)	\N
400	Welcome	\N
400	환상동화 Secret Story of the Swan	\N
400	Pretty	\N
400	회전목마 Merry-Go-Round	\N
400	Rococo	\N
400	With*One	\N
400	Secret Story of the Swan - Japanese Ver.	\N
400	Merry-Go-Round - Japanese Ver.	\N
401	EYES	\N
401	FIESTA	\N
401	DREAMLIKE(feat.Kwon Eunbi,Sakura,Kang Hyewon,Yena,Hitomi,Wonyoung)	\N
401	AYAYAYA(feat.Kwon Eunbi,Sakura,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Jo Yuri,Yujin)	\N
401	SO CURIOUS(feat.Yena,Lee Chae Yeon,Kim Chaewon,Minju,Nako,Hitomi,Jo Yuri,Yujin,Wonyoung)	\N
401	SPACESHIP	\N
401	우연이 아니야 DESTINY	\N
401	YOU & I	\N
401	DAYDREAM(feat.Kwon Eunbi,Lee Chae Yeon,Minju,Yujin)	\N
401	PINK BLUSHER(feat.Sakura,Kang Hyewon,Nako,Hitomi,Wonyoung)	\N
401	언젠가 우리의 밤도 지나가겠죠 SOMEDAY(feat.Yena,Kim Chaewon,Jo Yuri)	\N
401	OPEN YOUR EYES	\N
402	Vampire	\N
402	君以外 (Kimi Igai)	\N
402	Love Bubble(feat.Kwon Eunbi,Sakura,Kang Hyewon,Hitomi,Kim Chaewon,Jo Yuri)	\N
402	紫外線なんかぶっとばせ (Shigaisennanka Buttobase)(feat.Yena,Wonyoung,Lee Chae Yeon,Nako,Yujin,Minju)	\N
402	不機嫌Lucy (Fukigen Lucy)(feat.Yena,Lee Chae Yeon)	\N
403	Buenos Aires	\N
403	Tomorrow	\N
403	Target(feat.Kwon Eunbi,Yujin,Lee Chae Yeon,Sakura,Minju,Kang Hyewon)	\N
436	Hit 'Em	\N
436	DDI RO RI	\N
403	年下Boyfriend (Toshishita Boyfriend)(feat.Yena,Jo Yuri,Kim Chaewon,Wonyoung,Nako,Hitomi)	\N
403	Human Love(feat.Jo Yuri,Yujin)	\N
404	해바라기 Hey. Bae. Like it.	\N
404	비올레타 Violeta	\N
404	Highlight	\N
404	Really Like You	\N
404	Airplane	\N
404	하늘 위로 Up	\N
404	고양이가 되고 싶어 NEKONI NARITAI (Korean Ver.)	\N
404	기분 좋은 안녕 GOKIGEN SAYONARA (Korean Ver.)	\N
405	好きと言わせたい (Suki to Iwasetai)	\N
405	ケンチャナヨ (Gwaen Chanha Yo)	\N
405	ご機嫌サヨナラ (Gokigen Sayonara)(feat.Wonyoung,Yujin,Kwon Eunbi,Kang Hyewon,Lee Chae Yeon,Kim Chaewon,Hitomi)	\N
405	猫になりたい (Neko ni Naritai)(feat.Sakura,Yena,Jo Yuri,Nako,Minju)	\N
405	ダンスを思い出すまで (Dance o Omoidasumade)(feat.Wonyoung,Sakura)	\N
407	We on Fire	\N
407	Bewitched	\N
407	HOTLINE	\N
407	Sakura-iro Yell	\N
407	We on Fire (Korean Ver.)	\N
407	Bewitched (Korean Ver.)	\N
408	Back to Life	\N
408	Lunatic	\N
408	MISMATCH	\N
408	Rush	\N
408	Heartbreak Time Machine	\N
408	Who am I	\N
409	Go in Blind	\N
409	Run Wild	\N
409	Wolf type	\N
409	Extraordinary day	\N
409	Go in Blind (Korean ver.)	\N
409	Run Wild (Korean ver.)	\N
410	Extraordinary day	\N
411	Magic Hour	\N
411	&TEAM 'Wonderful World' Focus Cam (방과후 ver.)	\N
412	Yukiakari	\N
412	Deer Hunter	\N
412	Illumination	\N
412	Crescent moon’s wish	\N
412	Samidare	\N
412	Scar to Scar	\N
412	Maybe	\N
412	Aoarashi	\N
412	Koegawari	\N
412	Imprinted	\N
412	Jyuugoya	\N
412	Big Suki	\N
412	Beat the Odds	\N
412	MEME	\N
412	Samidare (Korean ver.)	\N
412	Scar to Scar (Korean ver.)	\N
412	Aoarashi (Korean ver.)	\N
412	Koegawari (Korean ver.)	\N
412	Yukiakari (Korean ver.)	\N
412	Deer Hunter (Korean ver.)	\N
412	Dropkick (Korean ver.)	\N
412	Feel the Pulse	\N
413	Jyuugoya	\N
413	Big suki	\N
414	Feel the Pulse	\N
415	Beat the odds	\N
416	BREAKOUT	\N
416	FOCUS	\N
416	CODE	\N
416	Can't Be Broken	\N
417	Zombie	\N
417	Colourz	\N
417	Back 2 Luv	\N
418	SLAY	\N
418	Oh Ma Ma God	\N
418	Make Me Feel	\N
420	TheFatRat & EVERGLOW - Ghost Light	\N
420	Ghost Light (Korean)	\N
420	Ghost Light (Sped Up)	\N
420	Ghost Light (Instrumental)	\N
420	Ghost Light (Slowed Down Reverb)	\N
421	EVERGLOW - Pirate (R3HAB Remix) (Official Visualizer)	\N
422	Back Together	\N
422	Pirate	\N
422	Don’t Speak	\N
422	Nighty Night	\N
422	Company	\N
423	PROMISE (for UNICEF PROMISE CAMPAIGN)	\N
424	FIRST	\N
424	DON′T ASK DON′T TELL	\N
424	PLEASE PLEASE	\N
425	Let Me Dance	\N
425	Let Me Dance (Instrumental)	\N
426	Baby Flower (Seoul Remix : Vendors)	\N
426	Baby Flower (Bangkok Remix : Kurtz)	\N
426	Baby Flower (Taipei Remix : ntrophy)	\N
426	Baby Flower (Tokyo Remix : Full8loom)	\N
427	Baby Flower -Japanese Ver.- - Baby Flower Japanese Version	\N
428	Sad Girls Schemin'	\N
428	Peer	\N
428	Baby Flower	\N
428	Type of Girl	\N
428	Sleek	\N
428	I Like That	\N
428	Me Myself Mode	\N
429	Tokimetique	\N
429	Tokimetique -Shin Sakiura Remix-	\N
429	Tokimetique TV Edit	\N
430	Are You Alive (깨어) (Inst.)	\N
430	Detective Soseol (추리소설) (Inst.)	\N
430	Firework Diary (어제 우리 불꽃놀이) (Inst.)	\N
430	Love Child (Inst.)	\N
430	Persona (Inst.)	\N
430	Too Hot (Inst.)	\N
430	Diablo (Inst.)	\N
430	Friend Zone (Inst.)	\N
430	Love2Love (Inst.)	\N
430	Fly Up (Inst.)	\N
430	Cameo Love (Inst.)	\N
430	Bubble Gum Girl (Inst.)	\N
430	Q&A (Inst.)	\N
430	Christmas Alone (Inst.)	\N
431	Magic Shine New Zone	\N
431	Fly Up(feat.neptune)	\N
431	Cameo Love(feat.moon)	\N
431	Bubble Gum Girl(feat.sun)	\N
431	Q&A(feat.zenith)	\N
431	Christmas Alone	\N
432	Password	\N
432	ヘッドフォン - Headphones	\N
432	トキメティック - Tokimetique	\N
432	TOKYO	\N
432	Oshare	\N
432	アンタイトル - Untitled	\N
432	### (∞! Ver.)	\N
433	Password	\N
434	Pink Power	\N
434	Pink Power (inst.)	\N
435	@% (Alpha Percent)	\N
435	깨어 (Are You Alive)	\N
435	추리소설 (Detective Soseol)	\N
435	어제 우리 불꽃놀이 (Firework Diary)	\N
435	Love Child	\N
435	Persona	\N
435	Too Hot	\N
435	Diablo	\N
435	Friend Zone	\N
435	Love2Love	\N
436	In my hands	\N
436	Favorite song	\N
436	Revenge	\N
437	BURNING UP (Rush Remix)	\N
438	BURNING UP	\N
439	ME ME ME	\N
440	HANDS UP	\N
440	DROP TOP	\N
440	MEOW	\N
440	BODY	\N
440	TOXIC	\N
440	LIT RIGHT NOW	\N
441	TOXIC	\N
441	BODY	\N
442	MEOW	\N
\.


--
-- Data for Name: votings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.votings (id_voting, name, start_date, end_date) FROM stdin;
\.


--
-- Name: albums_id_album_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.albums_id_album_seq', 1, false);


--
-- Name: fandoms_id_fandom_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fandoms_id_fandom_seq', 1, false);


--
-- Name: fans_users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fans_users_id_user_seq', 1, false);


--
-- Name: groups_id_group_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_group_seq', 1, false);


--
-- Name: idols_id_idol_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.idols_id_idol_seq', 1, false);


--
-- Name: labels_id_label_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.labels_id_label_seq', 1, false);


--
-- Name: votings_id_voting_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.votings_id_voting_seq', 1, false);


--
-- Name: active_groups active_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.active_groups
    ADD CONSTRAINT active_groups_pkey PRIMARY KEY (id_group);


--
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (id_album);


--
-- Name: disbanded_groups disbanded_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disbanded_groups
    ADD CONSTRAINT disbanded_groups_pkey PRIMARY KEY (id_group);


--
-- Name: fandom_colors fandom_colors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fandom_colors
    ADD CONSTRAINT fandom_colors_pkey PRIMARY KEY (id_fandom, color_identity);


--
-- Name: fandoms fandoms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fandoms
    ADD CONSTRAINT fandoms_pkey PRIMARY KEY (id_fandom);


--
-- Name: fans_fandoms fans_fandoms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_fandoms
    ADD CONSTRAINT fans_fandoms_pkey PRIMARY KEY (id_user, id_fandom);


--
-- Name: fans_users fans_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_users
    ADD CONSTRAINT fans_users_pkey PRIMARY KEY (id_user);


--
-- Name: fans_users fans_users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_users
    ADD CONSTRAINT fans_users_username_key UNIQUE (username);


--
-- Name: fans_vote_groups fans_vote_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_vote_groups
    ADD CONSTRAINT fans_vote_groups_pkey PRIMARY KEY (id_user, id_group, id_voting);


--
-- Name: group_idols group_idols_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_idols
    ADD CONSTRAINT group_idols_pkey PRIMARY KEY (id_group, id_idol, role);


--
-- Name: group_metrics group_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_metrics
    ADD CONSTRAINT group_metrics_pkey PRIMARY KEY (id_group, scraped_at);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id_group);


--
-- Name: hiatus_groups hiatus_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiatus_groups
    ADD CONSTRAINT hiatus_groups_pkey PRIMARY KEY (id_group);


--
-- Name: idols idols_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.idols
    ADD CONSTRAINT idols_pkey PRIMARY KEY (id_idol);


--
-- Name: labels labels_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_name_key UNIQUE (name);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id_label);


--
-- Name: tracks tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id_album, title);


--
-- Name: votings votings_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votings
    ADD CONSTRAINT votings_name_key UNIQUE (name);


--
-- Name: votings votings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votings
    ADD CONSTRAINT votings_pkey PRIMARY KEY (id_voting);


--
-- Name: idx_albums_id_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_id_group ON public.albums USING hash (id_group);


--
-- Name: idx_albums_release_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_release_date ON public.albums USING btree (release_date);


--
-- Name: idx_albums_release_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_release_group ON public.albums USING btree (release_date, id_group);


--
-- Name: idx_albums_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_albums_type ON public.albums USING hash (type);


--
-- Name: idx_groups_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groups_status ON public.groups USING hash (status);


--
-- Name: idx_tracks_id_album; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tracks_id_album ON public.tracks USING hash (id_album);


--
-- Name: groups trg_group_status_changed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_group_status_changed AFTER INSERT OR UPDATE OF status ON public.groups FOR EACH ROW EXECUTE FUNCTION public.group_status_changed();


--
-- Name: active_groups active_groups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.active_groups
    ADD CONSTRAINT active_groups_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: albums albums_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: disbanded_groups disbanded_groups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disbanded_groups
    ADD CONSTRAINT disbanded_groups_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fandom_colors fandom_colors_id_fandom_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fandom_colors
    ADD CONSTRAINT fandom_colors_id_fandom_fkey FOREIGN KEY (id_fandom) REFERENCES public.fandoms(id_fandom) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fandoms fandoms_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fandoms
    ADD CONSTRAINT fandoms_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fans_fandoms fans_fandoms_id_fandom_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_fandoms
    ADD CONSTRAINT fans_fandoms_id_fandom_fkey FOREIGN KEY (id_fandom) REFERENCES public.fandoms(id_fandom) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fans_fandoms fans_fandoms_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_fandoms
    ADD CONSTRAINT fans_fandoms_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.fans_users(id_user) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fans_vote_groups fans_vote_groups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_vote_groups
    ADD CONSTRAINT fans_vote_groups_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fans_vote_groups fans_vote_groups_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_vote_groups
    ADD CONSTRAINT fans_vote_groups_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.fans_users(id_user) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fans_vote_groups fans_vote_groups_id_voting_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans_vote_groups
    ADD CONSTRAINT fans_vote_groups_id_voting_fkey FOREIGN KEY (id_voting) REFERENCES public.votings(id_voting) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_idols group_idols_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_idols
    ADD CONSTRAINT group_idols_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_idols group_idols_id_idol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_idols
    ADD CONSTRAINT group_idols_id_idol_fkey FOREIGN KEY (id_idol) REFERENCES public.idols(id_idol) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_metrics group_metrics_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_metrics
    ADD CONSTRAINT group_metrics_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: groups groups_id_label_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_id_label_fkey FOREIGN KEY (id_label) REFERENCES public.labels(id_label) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: groups groups_id_parent_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_id_parent_group_fkey FOREIGN KEY (id_parent_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hiatus_groups hiatus_groups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiatus_groups
    ADD CONSTRAINT hiatus_groups_id_group_fkey FOREIGN KEY (id_group) REFERENCES public.groups(id_group) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tracks tracks_id_album_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_id_album_fkey FOREIGN KEY (id_album) REFERENCES public.albums(id_album) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ho5n818B7m4cYFWS6F3bsJfcUpcy8gXUseXVELISkdn2BMk24927VjhwFCL8yKw

