import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import clsx from "clsx";
import React from "react";
import styles from "./index.module.css";
import features from "/features";
import Logo from "@theme/Logo";

function Feature({ image, title, description }) {
	return (
		<div
			style={{
				display: "flex",
				flexDirection: "row",
				flexWrap: "wrap",
				gap: "10px",
				backgroundColor: "var(--tertiary)",
				border: "dashed",
				borderColor: "var(--ifm-toc-border-color)",
				borderRadius: "22px",
				paddingTop: "24px",
				paddingBottom: "24px",
				paddingLeft: "32px",
				paddingRight: "32px",
			}}
		>
			{image && (
				<div className="text--center">
					<img className={styles.featureSvg} alt={title} src={image} />
				</div>
			)}
			<div style={{ maxWidth: "256px" }}>
				<h3 style={{ marginBottom: "2%", textWrap: "wrap" }}>{title}</h3>
				<p
					style={{ marginBottom: "0px", lineHeight: "140%", textWrap: "wrap" }}
				>
					{description}
				</p>
			</div>
		</div>
	);
}

export function HomepageFeatures({ features }) {
	return (
		<section className={styles.features} style={{ padding: "1.5rem" }}>
			<div className="container">
				<div
					className="row"
					style={{ display: "flex", justifyContent: "center", gap: "16px" }}
				>
					{features.map((props, idx) => (
						<Feature key={idx} {...props} />
					))}
				</div>
			</div>
		</section>
	);
}

function HomepageHeader() {
	const { siteConfig } = useDocusaurusContext();
	const bannerImage = siteConfig.customFields.bannerImage;
	const hasBannerImage = bannerImage ? true : false;
	const heroBannerStyle = hasBannerImage
		? { backgroundImage: `url("${bannerImage}")` }
		: null;

	const titleClassName = clsx("hero__title", {
		[styles.titleOnBannerImage]: hasBannerImage,
	});
	const taglineClassName = clsx("hero__subtitle", {
		[styles.taglineOnBannerImage]: hasBannerImage,
	});

	return (
		<header
			className={clsx("hero", styles.heroBanner)}
			style={{
				padding: "4rem",
				paddingBottom: "6rem",
				background:
					"radial-gradient(ellipse 110.02% 110.02% at 50.00% 4.31%, rgba(191.05, 46.83, 255, 0.20) 0%, rgba(132.40, 32.45, 176.71, 0.14) 66%, rgba(0, 0, 0, 0) 100%)",
			}}
		>
			<div
				className="container"
				style={{
					display: "flex",
					flexDirection: "column",
					gap: "2rem",
				}}
			>
				<div>
					<Logo
						className="land__brand"
						imageClassName="land__logo"
						titleClassName="land__title text--truncate"
						style={{ display: "block" }}
					/>
					<style jsx>{`
						.land__logo img {
							height: 64px !important;
						}
					`}</style>
					<p className={taglineClassName}>{siteConfig.tagline}</p>
				</div>
				<div
					className={styles.buttons}
					style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem" }}
				>
					<Link className="button button--primary button--lg" to="/docs/intro">
						Get Started ❇︎
					</Link>
					<Link
						className="button button--primary button--lg button--outline"
						to="https://loneka.com/suite/discord"
					>
						Join the Discord
					</Link>
				</div>
			</div>
		</header>
	);
}

export default function Home() {
	const { siteConfig, tagline } = useDocusaurusContext();

	return (
		<Layout title={siteConfig.title} description={tagline}>
			<HomepageHeader />
			<main>
				<HomepageFeatures features={features} />
				<div className="container">{/***readme***/}</div>
			</main>
		</Layout>
	);
}
