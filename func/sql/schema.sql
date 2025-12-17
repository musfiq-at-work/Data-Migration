--
-- PostgreSQL database dump
--

\restrict w1Mfh2OPjcsHzLXIIlTN4GzPb64qQlx2TlM1gofmgizDDcfbeyB4XTYBTXKDzWp

-- Dumped from database version 16.10 (Debian 16.10-1.pgdg13+1)
-- Dumped by pg_dump version 18.1

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: actions; Type: TYPE; Schema: public; Owner: musfiq
--

CREATE TYPE public.actions AS ENUM (
    'UPDATE',
    'DELETE',
    'RESTORE'
);


ALTER TYPE public.actions OWNER TO musfiq;

--
-- Name: authorization_types; Type: TYPE; Schema: public; Owner: musfiq
--

CREATE TYPE public.authorization_types AS ENUM (
    'USER',
    'LEVEL'
);


ALTER TYPE public.authorization_types OWNER TO musfiq;

--
-- Name: delete_if_no_view(); Type: FUNCTION; Schema: public; Owner: musfiq
--

CREATE FUNCTION public.delete_if_no_view() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- If can_view is false or NULL, delete the row instead of updating
    IF NEW.can_view IS DISTINCT FROM TRUE THEN
        DELETE FROM level_permission WHERE id = OLD.id;
        RETURN NULL; -- stop the update
    END IF;

    RETURN NEW; -- allow update
END;
$$;


ALTER FUNCTION public.delete_if_no_view() OWNER TO musfiq;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.authorizations (
    id integer NOT NULL,
    module_id integer,
    level_id integer,
    is_enabled boolean DEFAULT true NOT NULL,
    name character varying(25) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.authorizations OWNER TO musfiq;

--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.authorizations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: banks; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.banks (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    country_id integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.banks OWNER TO musfiq;

--
-- Name: banks_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.banks_history (
    id integer NOT NULL,
    bank_id integer,
    name character varying(100),
    country_id integer,
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.banks_history OWNER TO musfiq;

--
-- Name: banks_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.banks_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.banks_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.banks ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: color_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.color_history (
    id integer NOT NULL,
    color_id integer,
    name character varying(50),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.color_history OWNER TO musfiq;

--
-- Name: color_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.color_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.color_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: colors; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.colors (
    id integer NOT NULL,
    name character varying(75) NOT NULL,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.colors OWNER TO musfiq;

--
-- Name: colors_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.colors ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.colors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    country_id integer,
    currencies_id integer,
    email character varying(30),
    phone_no character varying(18),
    city character varying(15),
    street text,
    zip_code character varying(6),
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.companies OWNER TO musfiq;

--
-- Name: companies_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.companies_history (
    id integer NOT NULL,
    company_id integer,
    name character varying(30),
    country_id integer,
    currencies_id integer,
    email character varying(30),
    phone_no character varying(18),
    city character varying(15),
    street text,
    zip_code character varying(6),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.companies_history OWNER TO musfiq;

--
-- Name: companies_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.companies_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.companies_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.companies ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    country_code character varying(5),
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.countries OWNER TO musfiq;

--
-- Name: countries_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.countries_history (
    id integer NOT NULL,
    name character varying(20),
    country_code character varying(5),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    country_id integer
);


ALTER TABLE public.countries_history OWNER TO musfiq;

--
-- Name: countries_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.countries_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.countries_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.countries ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: courier_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.courier_history (
    id integer NOT NULL,
    courier_id integer,
    name character varying(50) NOT NULL,
    address text,
    email character varying(50),
    contact_person character varying(30),
    phone_no character varying(18),
    website character varying(25),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.courier_history OWNER TO musfiq;

--
-- Name: courier_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.courier_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.courier_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: couriers; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.couriers (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    address text,
    email character varying(50),
    contact_person character varying(30),
    phone_no character varying(18),
    website character varying(25),
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.couriers OWNER TO musfiq;

--
-- Name: couriers_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.couriers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.couriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.currencies (
    id integer NOT NULL,
    name character varying(10),
    symbol character varying(2),
    currency_code character varying(5),
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.currencies OWNER TO musfiq;

--
-- Name: currencies_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.currencies_history (
    id integer NOT NULL,
    name character varying(10),
    symbol character varying(10),
    currency_code character varying(5),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    currency_id integer
);


ALTER TABLE public.currencies_history OWNER TO musfiq;

--
-- Name: currencies_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.currencies_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.currencies_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.currencies ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character(15) NOT NULL
);


ALTER TABLE public.departments OWNER TO musfiq;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.departments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.destinations (
    id integer NOT NULL,
    country_id integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    name character varying(50)
);


ALTER TABLE public.destinations OWNER TO musfiq;

--
-- Name: destinations_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.destinations_history (
    id integer NOT NULL,
    name character varying(50),
    country_id integer,
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    destination_id integer
);


ALTER TABLE public.destinations_history OWNER TO musfiq;

--
-- Name: destinations_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.destinations_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.destinations_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: destinations_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.destinations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fabric_suppliers; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.fabric_suppliers (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    address text,
    contact_person character varying(30),
    phone_no character varying(18),
    website character varying(30),
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    email character varying(50),
    country_id integer
);


ALTER TABLE public.fabric_suppliers OWNER TO musfiq;

--
-- Name: fabric_suppliers_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.fabric_suppliers_history (
    id integer NOT NULL,
    fabric_suppliers_id integer,
    name character varying(50),
    address text,
    contact_person character varying(30),
    phone_no character varying(18),
    website character varying(30),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    country_id integer,
    email character varying(50)
);


ALTER TABLE public.fabric_suppliers_history OWNER TO musfiq;

--
-- Name: fabric_suppliers_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.fabric_suppliers_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fabric_suppliers_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fabric_suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.fabric_suppliers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fabric_suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fabrics; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.fabrics (
    id integer NOT NULL,
    product_type_id integer,
    old_product_type_id integer,
    description character varying(255),
    composition text,
    name text,
    value integer,
    unit character varying(10),
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.fabrics OWNER TO musfiq;

--
-- Name: fabrics_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.fabrics_history (
    id integer NOT NULL,
    fabrics_id integer,
    name text,
    product_type_id integer,
    description character varying(255),
    composition text,
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    value integer,
    unit character varying(10)
);


ALTER TABLE public.fabrics_history OWNER TO musfiq;

--
-- Name: fabrics_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.fabrics_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fabrics_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fabrics_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.fabrics ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fabrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factories; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.factories (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    office_address text,
    factory_address text,
    email character varying(50),
    contact_person character varying(30),
    prefix character varying(10),
    phone_no character varying(75),
    website character varying(25),
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.factories OWNER TO musfiq;

--
-- Name: factories_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.factories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factory_bank; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.factory_bank (
    id integer NOT NULL,
    factory_id integer,
    bank_id integer,
    old_factory_id integer,
    old_bank_id integer,
    branch_name character varying(100),
    account_no character varying(20),
    account_name character varying(100),
    address text,
    swift_code character varying(15),
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.factory_bank OWNER TO musfiq;

--
-- Name: factory_bank_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.factory_bank_history (
    id integer NOT NULL,
    factory_bank_id integer,
    factory_id integer,
    bank_id integer,
    branch_name character varying(100),
    account_no character varying(20),
    account_name character varying(100),
    address text,
    swift_code character varying(15),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.factory_bank_history OWNER TO musfiq;

--
-- Name: factory_bank_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.factory_bank_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factory_bank_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factory_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.factory_bank ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factory_bank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factory_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.factory_history (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    office_address text,
    factory_address text,
    email character varying(50),
    contact_person character varying(30),
    prefix character varying(10),
    phone_no character varying(18),
    website character varying(25),
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    factory_id integer
);


ALTER TABLE public.factory_history OWNER TO musfiq;

--
-- Name: factory_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.factory_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factory_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fob_types; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.fob_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.fob_types OWNER TO musfiq;

--
-- Name: fob_types_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.fob_types ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fob_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: freight_term; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.freight_term (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.freight_term OWNER TO musfiq;

--
-- Name: freight_term_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.freight_term ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.freight_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: level_permission; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.level_permission (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    level_id integer NOT NULL,
    module_id integer NOT NULL,
    can_view boolean DEFAULT false NOT NULL,
    can_add boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    can_trace boolean DEFAULT false NOT NULL,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    department_id integer
);


ALTER TABLE public.level_permission OWNER TO musfiq;

--
-- Name: level_permission_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.level_permission_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    level_id integer NOT NULL,
    module_id integer NOT NULL,
    can_view boolean DEFAULT false NOT NULL,
    can_add boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    can_trace boolean DEFAULT false NOT NULL,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action public.actions NOT NULL,
    action_by uuid,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    level_permission_id uuid,
    past_action_time timestamp without time zone
);


ALTER TABLE public.level_permission_history OWNER TO musfiq;

--
-- Name: levels; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.levels (
    id integer NOT NULL,
    name character varying(15) NOT NULL
);


ALTER TABLE public.levels OWNER TO musfiq;

--
-- Name: levels_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.levels_history (
    id integer NOT NULL,
    level_id integer NOT NULL,
    name character varying(15),
    action public.actions NOT NULL,
    action_by uuid NOT NULL,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.levels_history OWNER TO musfiq;

--
-- Name: levels_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.levels_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.levels_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: levels_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.levels ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: login_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.login_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    attempted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip cidr NOT NULL,
    user_agent text NOT NULL,
    login_status boolean DEFAULT false NOT NULL
);


ALTER TABLE public.login_history OWNER TO musfiq;

--
-- Name: modules; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.modules (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    parent_module_id integer
);


ALTER TABLE public.modules OWNER TO musfiq;

--
-- Name: modules_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.modules ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: overseas_office_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.overseas_office_history (
    id integer NOT NULL,
    overseas_office_id integer,
    name character varying(25),
    email_address character varying(40),
    phone_no character varying(18),
    currency_id integer,
    country_id integer,
    city character varying(15),
    zip character varying(8),
    user_id uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    street text
);


ALTER TABLE public.overseas_office_history OWNER TO musfiq;

--
-- Name: overseas_office_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.overseas_office_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.overseas_office_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: overseas_offices; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.overseas_offices (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    email_address character varying(40),
    phone_no character varying(18),
    currency_id integer,
    country_id integer,
    city character varying(15),
    street text,
    zip character varying(8),
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.overseas_offices OWNER TO musfiq;

--
-- Name: overseas_offices_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.overseas_offices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.overseas_offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment_terms; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.payment_terms (
    id integer NOT NULL,
    term_id integer NOT NULL,
    tenor integer NOT NULL,
    term_description text NOT NULL,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.payment_terms OWNER TO musfiq;

--
-- Name: payment_terms_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.payment_terms_history (
    id integer NOT NULL,
    payment_terms_id integer,
    term_id integer,
    tenor integer,
    term_description text,
    user_id uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payment_terms_history OWNER TO musfiq;

--
-- Name: payment_terms_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.payment_terms_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payment_terms_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.payment_terms ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payment_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    module_id integer NOT NULL,
    can_view boolean DEFAULT false NOT NULL,
    can_add boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    added_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    can_trace boolean
);


ALTER TABLE public.permissions OWNER TO musfiq;

--
-- Name: permissions_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.permissions_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_id uuid,
    user_id uuid NOT NULL,
    module_id integer NOT NULL,
    can_view boolean DEFAULT false NOT NULL,
    can_add boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    can_trace boolean DEFAULT false NOT NULL,
    added_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action public.actions NOT NULL,
    action_by uuid,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.permissions_history OWNER TO musfiq;

--
-- Name: product_types; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.product_types (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    is_active boolean DEFAULT true,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.product_types OWNER TO musfiq;

--
-- Name: product_types_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.product_types_history (
    id integer NOT NULL,
    product_types_id integer,
    name character varying(25),
    is_active boolean,
    user_id uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.product_types_history OWNER TO musfiq;

--
-- Name: product_types_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.product_types_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_types_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_types_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.product_types ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    product_type_id integer,
    old_product_type_id integer,
    is_active boolean DEFAULT true,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.products OWNER TO musfiq;

--
-- Name: products_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.products_history (
    id integer NOT NULL,
    products_id integer,
    name character varying(255),
    product_types_id integer,
    is_active boolean,
    user_id uuid,
    past_action_time timestamp without time zone,
    action_type public.actions,
    action_by uuid,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products_history OWNER TO musfiq;

--
-- Name: products_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.products_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: terms; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.terms (
    id integer NOT NULL,
    name character varying(5) NOT NULL
);


ALTER TABLE public.terms OWNER TO musfiq;

--
-- Name: terms_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.terms ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tna_actions; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.tna_actions (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    department_id integer NOT NULL,
    lead_time integer NOT NULL,
    alert_before integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer
);


ALTER TABLE public.tna_actions OWNER TO musfiq;

--
-- Name: tna_actions_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.tna_actions_history (
    id integer NOT NULL,
    tna_action_id integer,
    name character varying(50) NOT NULL,
    department_id integer NOT NULL,
    lead_time integer NOT NULL,
    alert_before integer,
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tna_actions_history OWNER TO musfiq;

--
-- Name: tna_actions_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.tna_actions_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tna_actions_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tna_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.tna_actions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tna_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    session_token text NOT NULL,
    ip inet,
    browser text,
    login_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_sessions OWNER TO musfiq;

--
-- Name: users; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    first_name character varying(25) NOT NULL,
    last_name character varying(25),
    phone_no character varying(18),
    password text NOT NULL,
    email character varying(50),
    department_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_id character varying(20),
    hashed_password text NOT NULL,
    level_id integer,
    old_pk integer
);


ALTER TABLE public.users OWNER TO musfiq;

--
-- Name: users_history; Type: TABLE; Schema: public; Owner: musfiq
--

CREATE TABLE public.users_history (
    id integer NOT NULL,
    users_id uuid,
    first_name character varying(25),
    last_name character varying(25),
    phone_no character varying(18),
    password text,
    email character varying(50),
    department_id integer,
    level_id integer,
    user_id character varying(20),
    is_active boolean,
    hashed_password text,
    past_action_by uuid,
    past_action_time timestamp without time zone,
    action_by uuid,
    action_type public.actions,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users_history OWNER TO musfiq;

--
-- Name: users_history_id_seq; Type: SEQUENCE; Schema: public; Owner: musfiq
--

ALTER TABLE public.users_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: authorizations authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: banks_history banks_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks_history
    ADD CONSTRAINT banks_history_pkey PRIMARY KEY (id);


--
-- Name: banks banks_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: color_history color_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.color_history
    ADD CONSTRAINT color_history_pkey PRIMARY KEY (id);


--
-- Name: colors colors_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_pkey PRIMARY KEY (id);


--
-- Name: companies_history companies_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies_history
    ADD CONSTRAINT companies_history_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: countries_history countries_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.countries_history
    ADD CONSTRAINT countries_history_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: courier_history courier_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.courier_history
    ADD CONSTRAINT courier_history_pkey PRIMARY KEY (id);


--
-- Name: couriers couriers_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.couriers
    ADD CONSTRAINT couriers_pkey PRIMARY KEY (id);


--
-- Name: currencies_history currencies_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.currencies_history
    ADD CONSTRAINT currencies_history_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: destinations_history destinations_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations_history
    ADD CONSTRAINT destinations_history_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- Name: fabric_suppliers_history fabric_suppliers_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers_history
    ADD CONSTRAINT fabric_suppliers_history_pkey PRIMARY KEY (id);


--
-- Name: fabric_suppliers fabric_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers
    ADD CONSTRAINT fabric_suppliers_pkey PRIMARY KEY (id);


--
-- Name: fabrics_history fabrics_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics_history
    ADD CONSTRAINT fabrics_history_pkey PRIMARY KEY (id);


--
-- Name: fabrics fabrics_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics
    ADD CONSTRAINT fabrics_pkey PRIMARY KEY (id);


--
-- Name: factories factories_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factories
    ADD CONSTRAINT factories_pkey PRIMARY KEY (id);


--
-- Name: factory_bank_history factory_bank_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank_history
    ADD CONSTRAINT factory_bank_history_pkey PRIMARY KEY (id);


--
-- Name: factory_bank factory_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank
    ADD CONSTRAINT factory_bank_pkey PRIMARY KEY (id);


--
-- Name: factory_history factory_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_history
    ADD CONSTRAINT factory_history_pkey PRIMARY KEY (id);


--
-- Name: fob_types fob_types_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fob_types
    ADD CONSTRAINT fob_types_pkey PRIMARY KEY (id);


--
-- Name: freight_term freight_term_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.freight_term
    ADD CONSTRAINT freight_term_pkey PRIMARY KEY (id);


--
-- Name: level_permission_history level_permission_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission_history
    ADD CONSTRAINT level_permission_history_pkey PRIMARY KEY (id);


--
-- Name: level_permission level_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission
    ADD CONSTRAINT level_permission_pkey PRIMARY KEY (id);


--
-- Name: levels_history levels_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.levels_history
    ADD CONSTRAINT levels_history_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: login_history login_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT login_history_pkey PRIMARY KEY (id);


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- Name: overseas_office_history overseas_office_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_office_history
    ADD CONSTRAINT overseas_office_history_pkey PRIMARY KEY (id);


--
-- Name: overseas_offices overseas_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_offices
    ADD CONSTRAINT overseas_offices_pkey PRIMARY KEY (id);


--
-- Name: payment_terms_history payment_terms_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms_history
    ADD CONSTRAINT payment_terms_history_pkey PRIMARY KEY (id);


--
-- Name: payment_terms payment_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms
    ADD CONSTRAINT payment_terms_pkey PRIMARY KEY (id);


--
-- Name: permissions_history permissions_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: product_types_history product_types_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.product_types_history
    ADD CONSTRAINT product_types_history_pkey PRIMARY KEY (id);


--
-- Name: product_types product_types_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.product_types
    ADD CONSTRAINT product_types_pkey PRIMARY KEY (id);


--
-- Name: products_history products_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products_history
    ADD CONSTRAINT products_history_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: terms terms_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (id);


--
-- Name: tna_actions_history tna_actions_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions_history
    ADD CONSTRAINT tna_actions_history_pkey PRIMARY KEY (id);


--
-- Name: tna_actions tna_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions
    ADD CONSTRAINT tna_actions_pkey PRIMARY KEY (id);


--
-- Name: levels unique_name; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: users unique_user_id; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_user_id UNIQUE (user_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users_history users_history_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users_history
    ADD CONSTRAINT users_history_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: authorizations authorizations_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT authorizations_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id);


--
-- Name: authorizations authorizations_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT authorizations_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id);


--
-- Name: authorizations authorizations_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT authorizations_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: banks banks_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: banks banks_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: banks_history banks_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks_history
    ADD CONSTRAINT banks_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: banks_history banks_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.banks_history
    ADD CONSTRAINT banks_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: color_history color_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.color_history
    ADD CONSTRAINT color_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: color_history color_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.color_history
    ADD CONSTRAINT color_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: colors colors_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: companies companies_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: companies companies_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: companies companies_currencies_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_currencies_id_fkey FOREIGN KEY (currencies_id) REFERENCES public.currencies(id);


--
-- Name: companies_history companies_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies_history
    ADD CONSTRAINT companies_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: companies_history companies_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.companies_history
    ADD CONSTRAINT companies_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: countries countries_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: countries_history countries_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.countries_history
    ADD CONSTRAINT countries_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: countries_history countries_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.countries_history
    ADD CONSTRAINT countries_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: courier_history courier_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.courier_history
    ADD CONSTRAINT courier_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: courier_history courier_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.courier_history
    ADD CONSTRAINT courier_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: couriers couriers_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.couriers
    ADD CONSTRAINT couriers_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: currencies currencies_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: currencies_history currencies_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.currencies_history
    ADD CONSTRAINT currencies_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: currencies_history currencies_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.currencies_history
    ADD CONSTRAINT currencies_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: destinations destinations_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: destinations destinations_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: destinations_history destinations_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations_history
    ADD CONSTRAINT destinations_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: destinations_history destinations_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.destinations_history
    ADD CONSTRAINT destinations_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: fabric_suppliers fabric_suppliers_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers
    ADD CONSTRAINT fabric_suppliers_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: fabric_suppliers_history fabric_suppliers_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers_history
    ADD CONSTRAINT fabric_suppliers_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: fabric_suppliers_history fabric_suppliers_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers_history
    ADD CONSTRAINT fabric_suppliers_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: fabric_suppliers fabric_suppliers_to_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabric_suppliers
    ADD CONSTRAINT fabric_suppliers_to_country_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: fabrics fabrics_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics
    ADD CONSTRAINT fabrics_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: fabrics_history fabrics_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics_history
    ADD CONSTRAINT fabrics_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: fabrics_history fabrics_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics_history
    ADD CONSTRAINT fabrics_history_user_id_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: fabrics fabrics_product_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fabrics
    ADD CONSTRAINT fabrics_product_type_id_fkey FOREIGN KEY (product_type_id) REFERENCES public.product_types(id);


--
-- Name: factories factories_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factories
    ADD CONSTRAINT factories_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: factory_bank factory_bank_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank
    ADD CONSTRAINT factory_bank_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: factory_bank factory_bank_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank
    ADD CONSTRAINT factory_bank_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.banks(id);


--
-- Name: factory_bank factory_bank_factory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank
    ADD CONSTRAINT factory_bank_factory_id_fkey FOREIGN KEY (factory_id) REFERENCES public.factories(id);


--
-- Name: factory_bank_history factory_bank_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank_history
    ADD CONSTRAINT factory_bank_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: factory_bank_history factory_bank_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_bank_history
    ADD CONSTRAINT factory_bank_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: factory_history factory_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_history
    ADD CONSTRAINT factory_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: factory_history factory_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.factory_history
    ADD CONSTRAINT factory_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: fob_types fob_types_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.fob_types
    ADD CONSTRAINT fob_types_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: freight_term freight_term_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.freight_term
    ADD CONSTRAINT freight_term_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: level_permission level_permission_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission
    ADD CONSTRAINT level_permission_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: level_permission level_permission_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission
    ADD CONSTRAINT level_permission_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: level_permission_history level_permission_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission_history
    ADD CONSTRAINT level_permission_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: level_permission_history level_permission_history_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission_history
    ADD CONSTRAINT level_permission_history_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: level_permission_history level_permission_history_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission_history
    ADD CONSTRAINT level_permission_history_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE RESTRICT;


--
-- Name: level_permission_history level_permission_history_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission_history
    ADD CONSTRAINT level_permission_history_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE RESTRICT;


--
-- Name: level_permission level_permission_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission
    ADD CONSTRAINT level_permission_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE RESTRICT;


--
-- Name: level_permission level_permission_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.level_permission
    ADD CONSTRAINT level_permission_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE RESTRICT;


--
-- Name: levels_history levels_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.levels_history
    ADD CONSTRAINT levels_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: levels_history levels_history_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.levels_history
    ADD CONSTRAINT levels_history_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id);


--
-- Name: login_history login_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT login_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: modules modules_parent_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_parent_module_id_fkey FOREIGN KEY (parent_module_id) REFERENCES public.modules(id);


--
-- Name: overseas_office_history overseas_office_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_office_history
    ADD CONSTRAINT overseas_office_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: overseas_office_history overseas_office_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_office_history
    ADD CONSTRAINT overseas_office_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: overseas_offices overseas_offices_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_offices
    ADD CONSTRAINT overseas_offices_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: overseas_offices overseas_offices_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_offices
    ADD CONSTRAINT overseas_offices_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: overseas_offices overseas_offices_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.overseas_offices
    ADD CONSTRAINT overseas_offices_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- Name: payment_terms payment_terms_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms
    ADD CONSTRAINT payment_terms_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: payment_terms_history payment_terms_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms_history
    ADD CONSTRAINT payment_terms_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: payment_terms_history payment_terms_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms_history
    ADD CONSTRAINT payment_terms_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: payment_terms payment_terms_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.payment_terms
    ADD CONSTRAINT payment_terms_term_id_fkey FOREIGN KEY (term_id) REFERENCES public.terms(id);


--
-- Name: permissions permissions_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permissions_history permissions_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: permissions_history permissions_history_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permissions_history permissions_history_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE RESTRICT;


--
-- Name: permissions_history permissions_history_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE SET NULL;


--
-- Name: permissions_history permissions_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permissions permissions_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE RESTRICT;


--
-- Name: permissions permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: product_types product_types_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.product_types
    ADD CONSTRAINT product_types_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: product_types_history product_types_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.product_types_history
    ADD CONSTRAINT product_types_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: product_types_history product_types_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.product_types_history
    ADD CONSTRAINT product_types_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products products_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: products_history products_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products_history
    ADD CONSTRAINT products_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products_history products_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products_history
    ADD CONSTRAINT products_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products products_product_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_type_id_fkey FOREIGN KEY (product_type_id) REFERENCES public.product_types(id);


--
-- Name: tna_actions tna_actions_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions
    ADD CONSTRAINT tna_actions_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: tna_actions tna_actions_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions
    ADD CONSTRAINT tna_actions_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: tna_actions_history tna_actions_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions_history
    ADD CONSTRAINT tna_actions_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: tna_actions_history tna_actions_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.tna_actions_history
    ADD CONSTRAINT tna_actions_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE RESTRICT;


--
-- Name: users_history users_history_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users_history
    ADD CONSTRAINT users_history_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: users_history users_history_past_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users_history
    ADD CONSTRAINT users_history_past_action_by_fkey FOREIGN KEY (past_action_by) REFERENCES public.users(id);


--
-- Name: users users_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: musfiq
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id);


--
-- PostgreSQL database dump complete
--

\unrestrict w1Mfh2OPjcsHzLXIIlTN4GzPb64qQlx2TlM1gofmgizDDcfbeyB4XTYBTXKDzWp

