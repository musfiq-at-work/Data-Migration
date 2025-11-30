CREATE TABLE IF NOT EXISTS public.authorizations
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    module_id integer,
    level_id integer,
    is_enabled boolean NOT NULL DEFAULT true,
    name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT authorizations_pkey PRIMARY KEY (id),
    CONSTRAINT authorizations_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT authorizations_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT authorizations_updated_by_fkey FOREIGN KEY (updated_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.banks
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    country_id integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    CONSTRAINT banks_pkey PRIMARY KEY (id),
    CONSTRAINT banks_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT banks_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.countries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.companies
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    country_id integer,
    currencies_id integer,
    email character varying(30) COLLATE pg_catalog."default",
    phone_no character varying(18) COLLATE pg_catalog."default",
    city character varying(15) COLLATE pg_catalog."default",
    street text COLLATE pg_catalog."default",
    zip_code character varying(6) COLLATE pg_catalog."default",
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT companies_pkey PRIMARY KEY (id),
    CONSTRAINT companies_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT companies_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.countries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT companies_currencies_id_fkey FOREIGN KEY (currencies_id)
        REFERENCES public.currencies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.countries
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    country_code character varying(5) COLLATE pg_catalog."default",
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT countries_pkey PRIMARY KEY (id),
    CONSTRAINT countries_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.currencies
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(10) COLLATE pg_catalog."default",
    symbol character varying(2) COLLATE pg_catalog."default",
    currency_code character varying(5) COLLATE pg_catalog."default",
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT currencies_pkey PRIMARY KEY (id),
    CONSTRAINT currencies_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.departments
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character(15) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT departments_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.destinations
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    country_id integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    name character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT destinations_pkey PRIMARY KEY (id),
    CONSTRAINT destinations_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT destinations_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.countries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);



CREATE TABLE IF NOT EXISTS public.fabrics
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    product_type_id integer,
    old_product_type_id integer,
    description character varying(255) COLLATE pg_catalog."default",
    composition text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    value integer,
    unit character varying(10) COLLATE pg_catalog."default",
    old_pk integer,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fabrics_pkey PRIMARY KEY (id),
    CONSTRAINT fabrics_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fabrics_product_type_id_fkey FOREIGN KEY (product_type_id)
        REFERENCES public.product_types (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.level_permission
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    level_id integer NOT NULL,
    module_id integer NOT NULL,
    can_view boolean NOT NULL DEFAULT false,
    can_add boolean NOT NULL DEFAULT false,
    can_update boolean NOT NULL DEFAULT false,
    can_delete boolean NOT NULL DEFAULT false,
    can_trace boolean NOT NULL DEFAULT false,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    department_id integer,
    CONSTRAINT level_permission_pkey PRIMARY KEY (id),
    CONSTRAINT level_permission_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT level_permission_department_id_fkey FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT level_permission_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT level_permission_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.level_permission_history
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    level_permission_id uuid,
    level_id integer NOT NULL,
    module_id integer NOT NULL,
    can_view boolean NOT NULL DEFAULT false,
    can_add boolean NOT NULL DEFAULT false,
    can_update boolean NOT NULL DEFAULT false,
    can_delete boolean NOT NULL DEFAULT false,
    can_trace boolean NOT NULL DEFAULT false,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action actions NOT NULL,
    action_by uuid,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT level_permission_history_pkey PRIMARY KEY (id),
    CONSTRAINT level_permission_history_action_by_fkey FOREIGN KEY (action_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT level_permission_history_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT level_permission_history_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT level_permission_history_level_permission_id_fkey FOREIGN KEY (level_permission_id)
        REFERENCES public.level_permission (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT level_permission_history_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.levels
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(15) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT levels_pkey PRIMARY KEY (id),
    CONSTRAINT unique_name UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS public.levels_history
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    level_id integer NOT NULL,
    name character varying(15) COLLATE pg_catalog."default",
    action actions NOT NULL,
    action_by uuid NOT NULL,
    action_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT levels_history_pkey PRIMARY KEY (id),
    CONSTRAINT levels_history_action_by_fkey FOREIGN KEY (action_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT levels_history_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE IF NOT EXISTS public.login_history
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    attempted_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip cidr NOT NULL,
    user_agent text COLLATE pg_catalog."default" NOT NULL,
    login_status boolean NOT NULL DEFAULT false,
    CONSTRAINT login_history_pkey PRIMARY KEY (id),
    CONSTRAINT login_history_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.modules
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    parent_module_id integer,
    CONSTRAINT modules_pkey PRIMARY KEY (id),
    CONSTRAINT modules_parent_module_id_fkey FOREIGN KEY (parent_module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.overseas_offices
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    email_address character varying(40) COLLATE pg_catalog."default",
    phone_no character varying(18) COLLATE pg_catalog."default",
    currency_id integer,
    country_id integer,
    city character varying(15) COLLATE pg_catalog."default",
    street text COLLATE pg_catalog."default",
    zip character varying(8) COLLATE pg_catalog."default",
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    CONSTRAINT overseas_offices_pkey PRIMARY KEY (id),
    CONSTRAINT overseas_offices_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT overseas_offices_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.countries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT overseas_offices_currency_id_fkey FOREIGN KEY (currency_id)
        REFERENCES public.currencies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.payment_terms
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    term_id integer NOT NULL,
    tenor integer NOT NULL,
    term_description text COLLATE pg_catalog."default" NOT NULL,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    CONSTRAINT payment_terms_pkey PRIMARY KEY (id),
    CONSTRAINT payment_terms_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT payment_terms_term_id_fkey FOREIGN KEY (term_id)
        REFERENCES public.terms (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.permissions
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    module_id integer NOT NULL,
    can_view boolean NOT NULL DEFAULT false,
    can_add boolean NOT NULL DEFAULT false,
    can_update boolean NOT NULL DEFAULT false,
    can_delete boolean NOT NULL DEFAULT false,
    added_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    can_trace boolean,
    CONSTRAINT permissions_pkey PRIMARY KEY (id),
    CONSTRAINT permissions_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT permissions_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT permissions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.permissions_history
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    permission_id uuid,
    user_id uuid NOT NULL,
    module_id integer NOT NULL,
    can_view boolean NOT NULL DEFAULT false,
    can_add boolean NOT NULL DEFAULT false,
    can_update boolean NOT NULL DEFAULT false,
    can_delete boolean NOT NULL DEFAULT false,
    can_trace boolean NOT NULL DEFAULT false,
    added_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action actions NOT NULL,
    action_by uuid,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT permissions_history_pkey PRIMARY KEY (id),
    CONSTRAINT permissions_history_action_by_fkey FOREIGN KEY (action_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT permissions_history_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT permissions_history_module_id_fkey FOREIGN KEY (module_id)
        REFERENCES public.modules (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT permissions_history_permission_id_fkey FOREIGN KEY (permission_id)
        REFERENCES public.permissions (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT permissions_history_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.product_types
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    is_active boolean DEFAULT true,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    CONSTRAINT product_types_pkey PRIMARY KEY (id),
    CONSTRAINT product_types_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.products
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    product_type_id integer,
    old_product_type_id integer,
    is_active boolean DEFAULT true,
    added_by uuid,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    old_pk integer,
    CONSTRAINT products_pkey PRIMARY KEY (id),
    CONSTRAINT products_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT products_product_type_id_fkey FOREIGN KEY (product_type_id)
        REFERENCES public.product_types (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.terms
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying(5) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT terms_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.user_sessions
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    session_token text COLLATE pg_catalog."default" NOT NULL,
    ip inet,
    browser text COLLATE pg_catalog."default",
    login_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_sessions_pkey PRIMARY KEY (id),
    CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.users
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    first_name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(25) COLLATE pg_catalog."default",
    phone_no character varying(18) COLLATE pg_catalog."default",
    password text COLLATE pg_catalog."default" NOT NULL,
    email character varying(50) COLLATE pg_catalog."default",
    department_id integer NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_id character varying(20) COLLATE pg_catalog."default",
    hashed_password text COLLATE pg_catalog."default" NOT NULL,
    level_id integer,
    old_pk integer,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT unique_user_id UNIQUE (user_id),
    CONSTRAINT users_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT users_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS public.users_history
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid,
    first_name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(25) COLLATE pg_catalog."default",
    phone_no character varying(18) COLLATE pg_catalog."default",
    password text COLLATE pg_catalog."default" NOT NULL,
    email character varying(50) COLLATE pg_catalog."default",
    department_id integer NOT NULL,
    level_id integer NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    added_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action actions NOT NULL,
    action_by uuid,
    action_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_history_pkey PRIMARY KEY (id),
    CONSTRAINT users_history_action_by_fkey FOREIGN KEY (action_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT users_history_added_by_fkey FOREIGN KEY (added_by)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT users_history_department_id_fkey FOREIGN KEY (department_id)
        REFERENCES public.departments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT users_history_level_id_fkey FOREIGN KEY (level_id)
        REFERENCES public.levels (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT users_history_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
);