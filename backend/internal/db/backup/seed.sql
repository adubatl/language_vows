--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Debian 16.6-1.pgdg120+1)
-- Dumped by pg_dump version 16.6 (Debian 16.6-1.pgdg120+1)

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
-- Name: vows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vows (
    id character varying(255) NOT NULL,
    text text NOT NULL,
    language character varying(50) NOT NULL
);


ALTER TABLE public.vows OWNER TO postgres;

--
-- Data for Name: vows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vows (id, text, language) FROM stdin;
typescript-vg1yi9ihi	I shall never let implicit 'any' darken my codebase	typescript
typescript-7yqgpea7b	I solemnly swear to never use 'any' as a type escape hatch	typescript
typescript-ml98isvd6	I pledge to always define return types for public functions	typescript
\.


--
-- Name: vows vows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vows
    ADD CONSTRAINT vows_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

