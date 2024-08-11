# Corporate IT Security Strategy

A company with 1500 employees is facing diferent corporate security issues, data breaches and phishing attacks. The following document outlays a security strategy that aims to solve and mitigate the security risks within the organization and setup the necessary initiatives to properly protect the organization.

The following strategy understands that that a proper risk assesment & threat modelling exercise has been performed within the organization and so the critical assets have been identified, the threat landscape analyzed to understand to influence priorities when it comes to planning the implementation.

## Strategy

The security strategy proposed in this document is modelled around a zero trust framework and architecture where we work on the assumption that threats could be both internal and external and no entity should be trusted by default but rather authenticated (identities and devices) and authorized.

Hence so, identity security and access management and device security and management become paramount for this proposal.

It is also a very fundamental pillar of this proposal the necessity of a proper and lean IT Management and IT Organization implementation. Properly defined and designed IT systems together with the necessary tools to fulfill the bussines needs are of paramount importance to allow to implement a strong security framework in top of it. Unnecesary complexity, blurry or unexisting processes and an underdimensioned IT organization is in itself one of the biggest sources of introduction of IT security risks and should be paid the same or more attention to than the security strategy being defined here.

Even though, building around a zero trust framework and creating a proper IT organization and IT management solution is not enough to ensure complete security and other efforts need to be conducted to fully secure the organization. This strategy is going to also dig deeper into several other pillars that are very relevant to setup a strong foundation but its not going to be able to cover all the aspects that can be implemented but rather those that compose a strong foundation that can be then iterated upon based on the results of continous monitoring, risk assessment and threat modelling.

The strategy can be structured aroung 5 pillars:
- Identity Management and Security
- Endpoint Security and Management
- Context Aware Access Management
- Data Classification and Protection
- Shadow IT Discovery and SaaS Application Security
- Security Awareness and Training


### Identity and Access Management

As we have already mentioned Identity is one of the most important aspects of this strategy. Identity is going to be used to manage the access to every single system in the organization, IT or not. Hence, the management of identity needs to be properly structured and managed. 

Here we outlay several measures that should be in place but they do not compose at all of them, but rather an initial subset that provide an idea of the approach being taken.

#### The Identity Provider. Google Identity

The identity provider is the corner stone of the identity management and security. In order to be able to reduce password fatigue/reuse while providing centralized management of acces controls and authentication policies for all assets and saas applications, all of them need to be integrated into the identity provider for SSO authentication. This will require also investments in getting the necessary licensing for all the used tools in the organization.

#### Enable User and Device Monitoring

Activating visibility over the users and usage of Google Workspace as well as unfamiliar sign ins, suspicious emails and other threats related to the ecosystem is the first step towards building up the identity system so that whilst it is being built, we can already see what is currently happening and avoid easy to address issues.

#### MFA

Adding multi factor authentication is one of the most relevant security controls to implement as its presence greatly reduces the success of phising attacks, weak passwords or other attacks through which account credentials are compromised.

The allowed MFA methods should be different depending on the security level of the user where more privileged and critical identities should be restricted to only the most secure methods like FIDO keys and Certificates.

#### Password Manager

That is not always going to be possible, although it always should be the goal to do so, but certain platforms are not going to technically support this means of authentication and we will require the implementation of a complete and reliable password manager as well to fully secure all authentication means including break the glass accounts for all platforms.

1Pawssword is a very good candidate for that as it is a quite mature solution with lots of integrations including IaC and an upcoming product for Extended Access Management that can help on further strengthen the zero trust architecture introducing more controls, specially on non managed devices and helping where the MDM solution cannot reach.

#### HR Information is the single source of thruth 

The employee properties managed by the HR department of the organization are the properties that identify the different individuals within the organization. These properties together with additional security properties will classify the individual and that will match them to their security level of access.

Creating a common language and agreeing on what defines an employee is very important to have a solid foundation in top of which to build the access management system. If that classfication is not reliable and there is a plan to maintain it, ensuring proper health for the access management system will be impossible specially with the growth of the organization. 

#### RBAC 

RBAC should be implemented into all applications to provide granular access based on roles.


### Endpoint Security and Management

Another very important aspect of the corporate security strategy is device management. Security devices hold various types of data subject to being secured and also act as gateways to systems and protected data. It is hence very important to both protect and govern the devices both to protect the assets that live within those laptops and also and mainly to ensure the health of the devices that connect to corporate remote assets.

In this context, the main goals would be the following:
- Introduce an Endpoint Protection system like Microsoft Defender to protect the device against threats and ensure no malware or related threats are present.
- Introduce and Endpoint Verification System to ensure device compliance and health is up to par. This will be leveraged for context aware access management.
- Introduce an MDM System, since we are working with Google Identity and Google Workspace Services, it would make sense to onboard the Google Solution for that although there is other widely used solutions like Intune.

These three aspects would provide:
- Protection at endpoint level
- Measurements of the device health and compliance status to generate a device context
- Governance and control over the devices to widely spread configurations and security measures across all of the workforce devices.

### Context Aware Acces Management

With both a healthy identity architecture and endpoint protection and compliance verification measurements we have very rich data to conditionally provide access to resources based on that contextual data to not just base the authorization decisions on credentials but rather on a rich context.

Solutions like Google Identity Aware Proxy, Cloudflare Zero Trust, 1Password XAM, Google Identity Context Aware Authentication and Access Policies or Azure Entra Id Conditional access can be solutions which we can base the authorization decisions on. 

This can allow us to create flows for different applications where the access decisions are made upon that context, always starting by creating conditional rules for the most critical assets and personeel.

### Data Classification and Protection

On the data aspect, to be able to have a sound system for the management of data we first need to create a data classification strategy that encompases not only IT but also the production and development data in cloud assets and saas applications.

This strategy will define the criteria upon which we classify data. Once we have that criteria and the different levels of data classification we can then define security measures systems that handle that data must have.

Google Workspace Security, Atlassian Guard, and the security sections of the other mentioned tooling are going to be tools that we leverage to implement that.

As some of the more relevant threats are targeted towards the data being held in Google Workspace the focus should be done there and specially when it comes to email security which is fully provided in Goggle Workspace Security and configure proper security policies for email security as well as configuring DLP rules to prevent data leaks.

When it comes to preventing email threats like phishing we can use the platform to monitor and enhance the detectin and protection measures.

Afterwards we will need to introduce more generic tools that can help us implement broader protections for other tooling. Tools like Netskope can help us implement more generic protection measures.

### Shadow IT Discovery and SaaS Application Security

Not having visibility and governance over what the employees are using and where are they uploading their data too is one big security problem. If data is being moved to systems that are not known to IT and Security, those systems cannot be secured and monitored, and leaks can happen without the organization even realizing. 

To extend the previous initiatives into the higher percentage of the organization assets we neeed to be able to keep track of them and discover them when they are created outside of the proper procurement processes. Tools like BetterCloud, 1Password XAM, Cloudflare Zero Trust and others can help provide information on the IT usage of the employees and report on unsanctioned usage of applications within the organization so the situation can be regularized.

### Security Awareness and Training

Besides technical measures, communication and training of employees is paramount to reduce the risks of the organization. The human factor is usually the weakest link of the chain and training employees and makin them aware of risks and providing them with tools to mitigate them.

We can use Google Workspace Security Training, KnowBe4 and other similar tools for that.


## Implementation Plan

To implement the security strategy successfully, we need to ensure we can quickly put in place three main pillars:

- The Identity System in Google Identity
- Have a Data Classification Strategy and setup the classification system for Google Workspace and Atlassian as an initial step
- Full Device Endpoint Protection, Verification and MDM coverage
- Have visibilit over our systems.

A summary draft of the implementation plan to build these four pillars would be as follows:

- Start conversations on concepts on which we need agreement
    - Start an initiative with HR to create a common language throgh which we classify the employess
    - Start an initiative with legal and bussiness to define the Data Classfication Strategy
    - Start an initiative with IT to investigate and decide on the Best Device Management, Protection and Verification tools to use.
    - Start a conversation with external vendors to get a security training tool or provider.
    - Start a procurement conversation for Atlassian Guard.
    - Start a procurement conversation for a zero trust network provider to secure the network assets behind it so that we can treat both offices and remote locations under the zero trust paradigm.
- Implement an initial quick iteration to get some visibility and get quick gains on security posture
    - Scope and implement an initial security review and implement the necessary changes to obtain quick gains to increase the security of the most critical IT Systems. Through that process do a gap analysis that will influence further roadmap.
    - Do the necessary changes to obtain visibility on Google Workspace, Atlassian and Google Identity security events to monitor for active threats.
    - Implement a baseline configuration for the identity provider that sets the baseline security level
- As the conversations evolve and agreements are obtained bootstrap the following technical initiatives
    - Plan and Implement a rollout plan for Endpoint Security, MDM and Verification. This is a very long initiative and should be attacked in the written order. 
    - Plan and Implement a rollout plan for Identity Security for the already known systems. Integrate them all into SSO and analyze the required access for the different organizational roles and provide RBAC rules for each of those tools
    - Plan and Implement the data classification efforts for the already known systems focusing on the main known systems Google Workspace and Atlassian
    - Plan and execute security trainings for employees.
    - Plan and implement the zero trust network deployment and expose any private network service through it.
- Once we have set up the foundational setup for identity and device management as well as contextual acccess management.
    - Start vendor explorations for Shadow IT Discovery tools to start to obtain visiblity on further tooling we will need to secure.
    - Start initiatives to introduce advanced security measures and iterate the contextual security controls.
    - Mature the mail security systems and introduce DLP rules and other policies to prevent data leaks, also leveraging the results of the data classification.
- Extend the implemented controls to the newly found tools and integrate into the IT Security Framework.
- Use the gained knowledge during implementation and based on monitoring tooling to iterate over the solution.
- ...

## Required Resources

- A cross-team to deploy and manage the Endpoint Security Systems and Identity Security and the Zero Trust Network Layer. This team will be more technical and will become the senior resources of the IT department specialized on the systems being deployed.
- A dedicated team for Data Security that will lead the data security efforts. This team will be a less technical team and will be more focused on data classification and ensuring that we add the necessary controls and mitigate the risks of data leak. This team will have some cross with the detection and response team.
- A dedicated detection and response team dedicated to implementing the Detection and Response Systems.

> Within each of the teams there should be tech leads with the ability to deliver the overall strategy vision for their are and structure and lead the implementation. Some of the resources could be obtained from third parties as once the implementation efforts for building up all the systems is finished there will not be a need for such a big capacity.

> The size of the teams will directly influence the speed at which we can deliver, considering that all teams are created at start and are up to date of all being done from the start hence there not being a performance degradation for adding capacity at a later point in the projects.