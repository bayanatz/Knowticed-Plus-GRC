///*************************** FILE INFO ****************************///
/// Purpose: Full-screen Terms & Conditions page.
/// Original markdown authored 25/September/2023 by Mazen Shabaan.
/// Restored after removal; the former MarkDownWidget (mark_down.dart) is
/// inlined here as _TermsMarkdown so the page is self-contained and that
/// file stays deleted.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/filters_appbar.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.02.h),
            child: const FiltersAppBar(
              hideIcon: true,
              imageUrl: "assets/icons_assets/settings_assets/requests_edit_document.svg",
              title: "Terms And Conditions",
            ),
          ),
          const Expanded(child: _TermsMarkdown()),
        ],
      ),
    );

    // On phones this is pushed as its own route, so it owns a Scaffold.
    // On tablet it is embedded inside settings_layout's Column, which gives
    // unbounded height — a Scaffold there would try to be infinitely tall.
    // Same split PrivacyStatementPage uses.
    if (isMobile) {
      return Scaffold(body: SafeArea(child: content));
    }

    return SizedBox(
      width: double.infinity,
      height: isPortrait ? 0.75.h : 0.69.h,
      child: content,
    );
  }
}

class _TermsMarkdown extends StatelessWidget {
  const _TermsMarkdown();

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 0.012.h : 0.008.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Markdown(
        data: '''# Knowticed Terms Of Service
In order to provide our services (as defined below) through our apps, services, features, software, or Website, we need to obtain your agreement to our terms of service ('Terms').

# About Our Services
- Privacy and security principles: since we started Knowticed, we've built our services with strong privacy and security principles in mind.
- Connecting you with other people: we provide, and always strive to improve, ways for you to connect with other Knowticed users including through messages, voice and video calls, sending images and video, showing your status, and sharing your location with others when you choose. Knowticed works with partners, service providers, and affiliated companies to help us provide ways for you to connect with their services.
- Ways to improve our services: we analyze how you make use of Knowticed, in order to improve our services, including helping businesses who use Knowticed measure the effectiveness and distribution of their services and messages. Knowticed uses the information it has and also works with partners, service providers, and affiliated companies to do this.
- Communicating with businesses: we provide, and always strive to improve, ways for you and businesses and other organizations, to communicate with each other using our services, such as through notifications, product and service updates, and marketing.
- Safety, security, and integrity: we work to protect the safety, security, and integrity of our services. This includes appropriately dealing with abusive people and activity violating our terms. We work to prohibit misuse of our services including harmful conduct towards others, violations of our terms and policies, and address situations where we may be able to help support or protect our community. If we learn of people or activity like this, we will take appropriate action, including by removing such people or activity or contacting law enforcement. Any such removal will be in accordance with the “termination” section below.
- Enabling access to our services: to operate our global services, we might need to store and distribute content and information in data centers and systems around the world, including outside your country of residence. The use of this global infrastructure is necessary and essential to provide our services. This infrastructure may be owned or operated by our service providers.
- If you are a Knowticed user located in the United States or Canada, our terms contain a binding arbitration provision, which states that, except if you opt-out and except for certain types of disputes, Knowticed and you agree to resolve all disputes (defined below) through binding individual arbitration, which means that you waive any right to have those disputes decided by a judge or jury and that you waive your right to participate in class actions, class arbitrations, or representative actions. Please read the “special arbitration provision for United States or Canada users” section below to learn more.
- You must register for our services using accurate information, provide your current mobile phone number, and, if you change it, update your mobile phone number using our in-app edit profile feature. You agree to receive text messages and phone calls (from us or our third-party providers) with codes to register for our services if necessary.
- You must be at least 13 years old to register for and use our services (or such greater age required in your country or territory for you to be authorized to register for and use our services without parental approval). In addition to being of the minimum required age to use our services under applicable law, if you are not old enough to have authority to agree to our terms in your country or territory, your parent or guardian must agree to our terms on your behalf. Please ask your parent or guardian to read these terms with you.
- You must provide certain devices, software, and data connections to use our services, which we otherwise do not supply. In order to use our services, you consent to manually or automatically download and install updates to our services. You also consent to our sending you notifications via our services from time to time, as necessary to provide our services to you.
- You are responsible for all carrier data plans, internet fees, and other fees and taxes associated with your use of our services.


# Privacy Policy And User Data
Knowticed cares about your privacy. Knowticed’s privacy policy describes our data (including message)
Practices, including the types of information we receive and collect from you, how we use and share this
Information, and your rights in relation to the processing of information about you.

# Acceptable Use Of Our Services

- You must use our services according to our terms and posted policies. If you violate our terms or policies, we may take action with respect to your account, including disabling or suspending your account and, if we do, you agree not to create another account without our permission. Disabling or suspending your account will be in accordance with the “termination” section below.

- You must access and use our services only for legal, authorized, and acceptable purposes. You will not use (or assist others in using) our services in ways that:

    **a)** Violate, misappropriate, or infringe the rights of Knowticed, our users, or others, including privacy, publicity, intellectual property, or other proprietary rights;

    **b)** Are illegal, obscene, defamatory, threatening, intimidating, harassing, hateful, racially or ethnically offensive, or instigate or encourage conduct that would be illegal or otherwise inappropriate, such as promoting violent crimes, endangering or exploiting children or others, or coordinating harm;

    **c)** Involve publishing falsehoods, misrepresentations, or misleading statements;

    **d)** Impersonate someone;

    **e)** Involve sending illegal or impermissible communications such as bulk messaging, auto-messaging, auto-dialing, and the like;

    **f)** Involve any non-personal use of our services unless otherwise authorized by us.

- You must not (or assist others to) directly, indirectly, through automated or other means, access, use, copy, adapt, modify, prepare derivative works based upon, distribute, license, sublicense, transfer, display, perform, or otherwise exploit our services in impermissible or unauthorized manners, or in ways that burden, impair, or harm us, our services, systems, our users, or others, including that you must not directly or through automated means:

    **a)** Reverse engineer, alter, modify, create derivative works from, decompile, or extract code from our services;

    **b)** Send, store, or transmit viruses or other harmful computer code through or onto our services;

    **c)** Gain or attempt to gain unauthorized access to our services or systems;

    **d)** Interfere with or disrupt the safety, security, confidentiality, integrity, availability, or performance of our services;

    **e)** Create accounts for our services through unauthorized or automated means;

    **f)** Collect information of or about our users in any impermissible or unauthorized manner;

    **g)** Sell, resell, rent, or charge for our services or data obtained from us or our services in an unauthorized manner;

    **h)** Distribute or make our services available over a network where they could be used by multiple devices at the same time, except as authorized through tools we have expressly provided via our services;

    **i)** Create software or APIs that function substantially the same as our services and offer them for use by third parties in an unauthorized manner;

    **j)** Misuse any reporting channels, such as by submitting fraudulent or groundless reports or appeals.


- You are responsible for keeping your device and your Knowticed account safe and secure, and you must notify us promptly of any unauthorized use or security breach of your account or our services.

# Third-Party Services

Our services may allow you to access, use, or interact with third-party websites, apps, content, and other
Products and services. Please note that these terms and our privacy policy apply only to the use of our services. When you use third-party products or services, their terms and privacy policies will govern your use of those products or services.

# Licenses
- Knowticed does not claim ownership of the information that you submit for your Knowticed account or through our services. You must have the necessary rights to such information that you submit for your Knowticed account or through our services and the right to grant the rights and licenses in our terms.
- We own all copyrights, trademarks, domains, logos, trade dress, trade secrets, patents, and other intellectual property rights associated with our services. You may not use our copyrights, trademarks (or any similar marks), domains, logos, trade dress, trade secrets, patents, and other intellectual property rights unless you have our express permission and except in accordance with our brand guidelines. You may use the trademarks of our affiliated companies only with their permission, including as authorized in any published brand guidelines.
- In order to operate and provide our services, you grant Knowticed a worldwide, non-exclusive, royalty-free, sublicensable, and transferable license to use, reproduce, distribute, create derivative works of, display, and perform the information (including the content) that you upload, submit, store, send, or receive on or through our services. The rights you grant in this license are for the limited purpose of operating and providing our services (such as to allow us to display your profile picture, transmit your messages, and store your undelivered messages on our servers for up to 30 days as we try to deliver them).
- We grant you a limited, revocable, non-exclusive, non-sublicensable, and non-transferable license to use our services, subject to and in accordance with our terms. This license is for the sole purpose of enabling you to use our services in the manner permitted by our terms. No licenses or rights are granted to you by implication or otherwise, except for the licenses and rights expressly granted to you.

# Reporting Third-Party Copyright, Trademark, And Other Intellectual Property Infringement

To report claims of third-party copyright, trademark, or other intellectual property infringement, please
Visit our intellectual property policy. We may take action with respect to your account, including disabling
Or suspending your account, if you clearly, seriously, or repeatedly infringe the intellectual property rights
Of others or where we are required to do so for legal reasons. Disabling or suspending your account will be
In accordance with the “termination” section below.

# Disclaimers And Releases

You use our services at your own risk and subject to the following disclaimers:
- We are providing our services on an “as is” basis without any express or implied warranties, including, but not limited to, warranties of merchantability, fitness for a particular purpose, title, non-infringement, and freedom from computer virus or other harmful code.
- We do not warrant that any information provided by us is accurate, complete, or useful, that our services will be operational, error-free, secure, or safe, or that our services will function without disruptions, delays, or imperfections.
- We do not control, and are not responsible for, controlling how or when our users use our services or the features, services, and interfaces our services provide.
- We are not responsible for and are not obligated to control the actions or information (including content) of our users or other third-parties.
- You release us, our subsidiaries, affiliates, and our and their directors, officers, employees, partners, and agents (together, the “Knowticed parties”) from any claim, complaint, cause of action, controversy, dispute, or damages (together, “claim”), known and unknown, relating to, arising out of, or in any way connected with any such claim you have against any third parties.
- Your rights with respect to the Knowticed parties are not modified by the foregoing disclaimer if the laws of your country or territory of residence, applicable as a result of your use of our services, do not permit it.
- If you are a United States resident, you waive any rights you may have under California civil code §1542, or any other similar applicable statute or law of any other jurisdiction, which says that: a general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that if known by him or her would have materially affected his or her settlement with the debtor or released party.

# Limitation Of Liability

The Knowticed parties will not be liable to you for any lost profits or consequential, special, punitive, indirect, or incidental damages relating to, arising out of, or in any way in connection with our terms, us, or our services (however caused and on any theory of liability, including negligence), even if the Knowticed parties have been advised of the possibility of such damages. Our aggregate liability relating to, arising out of, or in any way in connection with our terms, us, or our services will not exceed the greater of one hundred dollars (\$1) or the amount you have paid us in the past twelve months. The foregoing disclaimer of certain damages and limitation of liability
Will apply to the maximum extent permitted by applicable law. The laws of some states or jurisdictions may not allow the exclusion or limitation of certain damages, so some or all of the exclusions and limitations set forth above may not apply to you. Notwithstanding anything to the contrary in our terms, in such cases, the liability of the Knowticed parties will be limited to the fullest extent permitted by applicable law.

# Indemnification

If anyone brings a claim ('third-party claim') against us related to your actions, information, or content on Knowticed, or any other use of our services by you, you will, to the maximum extent permitted by applicable law, indemnify, and hold the Knowticed parties harmless from and against all liabilities, damages, losses, and expenses of any kind (including reasonable legal fees and costs) relating to, arising out of, or in any way in connection with any of the following:

**a)** Your access to or use of our services, including information and content provided in connection therewith;

**b)** Your breach of our terms or applicable law;

**c)** Any misrepresentation made by you.

You will cooperate as fully as required by us in the defense or settlement of any third-party claim. Your rights with respect to Knowticed are not modified by the foregoing indemnification if the laws of your country or territory of residence, applicable as a result of your use of our services, do not permit it.

# Dispute Resolution
- If you are a Knowticed user located in the United States or Canada, the “special arbitration provision for United States or Canada users” section below applies to you. Please also read that section carefully and completely. If you are not subject to the “special arbitration provision for United States or Canada users” section below, you agree that any claim or cause of action you have against Knowticed relating to, arising out of, or in any way in connection with our terms or our services, and for any claim or cause of action that Knowticed files against you, you and Knowticed agree that any such claim or cause of action (each, a “dispute,” and together, “disputes”) will be resolved exclusively in the United  States district court for the northern district of California or a state court located in San Mateo County in California, and you agree to submit to the personal jurisdiction of such courts to litigate any such claim or cause of action, and the laws of the state of California will govern any such claim or cause of action without regard to conflict of law provisions. Without prejudice to the foregoing, you agree that, in our sole discretion, we may elect to resolve any dispute we have with you that is not subject to arbitration in any competent court in the country in which you reside that has jurisdiction over the dispute.
- The laws of the state of California govern our terms, as well as any disputes, whether in court or arbitration, which might arise between Knowticed and you, without regard to conflict of law provisions.
- These terms also limit the time you have to bring a claim or dispute, including the time to start arbitration or, if permissible, a court action or small claims proceeding to the fullest extent permitted by applicable law. We and you agree that for any dispute (except for the excluded disputes defined below) we and you must bring claims (including commencing an arbitration proceeding) within one month after the dispute first arose; otherwise, such dispute is permanently barred. This means that if we or you do not bring a claim (including commencing an arbitration) within one month after the dispute first arose, then the arbitration will be dismissed because it was started too late. See below: special arbitration provision for United States or Canada users.

# Availability And Termination Of Our Services

- We are always trying to improve our services. That means we may expand, add, or remove our services, features, functionalities, and the support of certain devices and platforms. Our services may be interrupted, including for maintenance, repairs, upgrades, or network or equipment failures. We may discontinue some or all of our services, including certain features and the support for certain devices and platforms, at any time. Events beyond our control may affect our services, such as events in nature and other force majeure events.
- Although we hope you remain a Knowticed user, you can terminate your relationship with Knowticed anytime for any reason by deleting your account. For instructions on how to do so, please visit the Android, iPhone articles in our help center.

- We may modify, suspend, or terminate your access to or use of our services anytime for any reason, such as if you violate the letter or spirit of our terms or create harm, risk, or possible legal exposure for us, our users, or others.
- We may also disable or delete your account if it does not become active after account registration or if it remains inactive for an extended period of time. The following provisions will survive any termination of your relationship with Knowticed: “licenses,” “disclaimers and release,” “limitation of liability,” “indemnification,” “dispute resolution,” “availability and termination of our services,” “other,” and “special arbitration provision for United States or Canada users.”

# Other

- Unless a mutually executed agreement between you and us states otherwise, our terms make up the entire agreement between you and us regarding Knowticed and our services and supersede any prior agreements.
- We reserve the right to designate in the future that certain of our services are governed by separate terms (where, as applicable, you may separately consent).
- Our services are not intended for distribution to or use in any country or territory where such distribution or use would violate local law or would subject us to any regulations in another country or territory. We reserve the right to limit our services in any country or territory.
- You will comply with all applicable united states and non-united states export control and trade sanctions laws (“export laws”). You will not, directly or indirectly, export, re-export, provide, or otherwise transfer our services:

    **a)** To any individual, entity, territory, or country prohibited by export laws;

    **b)** To anyone on united states or non-united states government restricted parties lists;

    **c)** For any purpose prohibited by export laws, including nuclear, chemical, or biological weapons, or missile technology applications without the required government authorizations. You will not use or download our services if you are located in a restricted country or territory if you are currently listed on any united states or non-united states restricted parties list, or for any purpose prohibited by export laws, and you will not disguise your location through IP proxying or other methods.

- Our terms are written in English (United States). Any translated version is provided solely for your convenience. To the extent any translated version of our terms conflicts with the English version, the English version controls. Any amendment to or waiver proposed by you of our terms requires our express consent.
- We may amend or update these terms. We will provide you notice of material amendments to our terms, as appropriate, and update the “last modified” date at the top of our terms. Your continued use of our services confirms your acceptance of our terms, as amended. We hope you will continue using our services, but if you do not agree to our terms, as amended, you must stop using our services by deleting your account.
- All of our rights and obligations under our terms are freely assignable by us to any of our affiliates or in connection with a merger, acquisition, restructuring, or sale of assets, or by operation of law or otherwise, and we may transfer your information to any of our affiliates, successor entities, or new owner. In the event of such an assignment, these terms will continue to govern your relationship with such third-party. We hope you will continue using our services, but if you do not agree to such an assignment, you must stop using our services by deleting your account after having been notified of the assignment.
- You will not transfer any of your rights or obligations under our terms to anyone else without our prior written consent.
- Nothing in our terms will prevent us from complying with the law.
- Except as contemplated herein, our terms do not give any third-party beneficiary rights.
- If we fail to enforce any of our terms, it will not be considered a waiver.
- If any provision of these terms is found to be unlawful, void, or for any reason is unenforceable, then that provision shall be deemed amended to the minimum extent necessary to make it enforceable, and if it cannot be made enforceable then it shall be deemed severable from our terms and shall not affect the validity and enforceability of the remaining provisions of our terms, and the remaining portion of our terms will remain in full force and effect except as set forth in the “special arbitration provision for United States or Canada users” section below.
- We reserve all rights not expressly granted by us to you. In certain jurisdictions, you may have legal rights as a consumer, and our terms are not intended to limit such consumer legal rights that may not be waived by contract.
- We always appreciate your feedback or other suggestions about Knowticed and our services, but you understand that you have no obligation to provide feedback or suggestions and that we may use your feedback or suggestions without any restriction or obligation to compensate you for them.

# Special Arbitration Provision For United States Or Canada Users

Please read this section carefully because it contains additional provisions applicable only to our United States and Canada users. If you are a Knowticed user located in the United States or Canada, you and we agree to submit all disputes to binding individual arbitration, except for those that involve intellectual property disputes and except those that can be brought in small claims court. This means you waive your right to have such disputes resolved in court by a judge or jury. Finally, you may bring a claim only on your behalf, and not on behalf of any official or other person, or class of people. You waive your right to participate in or have your dispute heard and resolved as, a class action, a class arbitration, or a representative action.

“excluded dispute” means any dispute relating to the enforcement or infringement of your or our intellectual property rights (such as copyrights, trademarks, domains, logos, trade dress, trade secrets, and patents) or efforts to interfere with our services or engage with our services in unauthorized ways (for example, automated ways). For clarity and notwithstanding the foregoing, those disputes relating to, arising out of, or in any way in connection with your rights of privacy and publicity are not excluded disputes.

Federal arbitration act: The United States federal arbitration act governs the interpretation and enforcement of this “special arbitration provision for United States or Canada users” section, including any question whether a dispute between Knowticed and you are subject to arbitration.

Agreement to arbitrate for Knowticed users located in the United States or Canada: for Knowticed users who live in the United States or Canada, Knowticed and you each agree to waive the right to a trial by judge or jury for all disputes, except for the excluded disputes. Knowticed and you agree that all disputes (except for the excluded disputes), including those relating to, arising out of, or in any way in connection with your rights of privacy and publicity, will be resolved through final and binding arbitration. Knowticed and you agree not to combine a dispute that is subject to arbitration under our terms with a dispute that is not eligible for arbitration under our terms. Before you commence arbitration of a dispute, you must provide us with a written notice of dispute that includes your (a) name; (b) residence address; (c) username; (d) email address or phone number you use for your Knowticed account; (e) a detailed description of the dispute; and (f) the relief you seek. Any notice of dispute you send to us should be emailed to support@knowticedplus.com. Before we commence an arbitration, we will send you a notice of the dispute to the email address you provide, or other appropriate means. If we are unable to resolve a dispute within sixty (90) days after the notice of dispute is received, you or we may commence arbitration.

The arbitration will be administered by the American Arbitration Association (“AAA”) under its commercial arbitration rules in effect at the time the arbitration is started, including the optional rules for emergency measures of protection and the supplementary procedures for consumer-related disputes (together, the “AAA rules”). The arbitration will be presided over by a single arbitrator selected in accordance with the AAA rules. The AAA rules, information regarding initiating a dispute, and a description of the arbitration process are available at www.adr.org. Issues relating to the scope and enforceability of the arbitration provision are for a court to decide. The location of the arbitration and the allocation of fees and costs for such arbitration shall be determined in accordance with the AAA rules.

Opt-out procedure: you may opt-out of this agreement to arbitrate. If you do so, neither we nor you can require the other to participate in an arbitration proceeding. To opt-out, you must notify us in writing postmarked within 60 days of the later of: (a) the date that you first accepted our terms; and (b) the date you became subject to this arbitration provision. You must use this email address to opt-out: support@knowticedplus.com

You must include: (i) your name and residence address; (ii) the mobile phone number associated with your account; and (iii) a clear statement that you want to opt-out of our terms’ agreement to arbitrate. Small claims court. As an alternative to arbitration, if permitted by your local “small claims” court’s rules, you may bring your dispute in your local “small claims” court, as long as the matter advances on an individual (non-class) basis.

No class actions, class arbitrations, or representative actions for users located in the United States or Canada: we and you each agree that if you are a Knowticed user located in the United States or Canada, each of us and you may bring disputes against the other only on its or your behalf, and not on behalf of any other person or entity, or any class of people. We and you each agree not to participate in a class action, a class-wide arbitration, disputes brought in a private attorney general or representative capacity, or consolidated disputes involving any other person or entity in connection with any dispute. If there is a final judicial determination that any particular dispute (or a request for particular relief) cannot be arbitrated in accordance with this provision's limitations, then only that dispute (or only that request for relief) may be brought in court. All other disputes (or requests for relief) remain subject to this provision. Place to file permitted court actions. If you opt-out of the agreement to arbitrate, if your dispute is an excluded dispute, or if the arbitration agreement is found to be unenforceable, you agree to be subject to the applicable provision in the “dispute resolution” section set forth above.
''',
        onTapLink: (text, url, title) async {},
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: AppFontStyle.cairoRegularStyle.copyWith(
              color: Theme.of(context).colorScheme.scrim,
              fontSize: isTablet
                  ? FontConstants.fontSize020.h
                  : FontConstants.fontSize016.h,
              height: 1.2),
          h1: AppFontStyle.cairoRegularStyle.copyWith(
              color: Theme.of(context).colorScheme.inverseSurface,
              fontSize: isTablet
                  ? FontConstants.fontSize023.h
                  : FontConstants.fontSize020.h,
              height: 1.3),
        ),
      ),
    );
  }
}
