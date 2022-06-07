# Glossary

Please mind that some of these definitions are drastic simplifications. This is
not intended to be medically accurate but instead to be minimal to achieve
understanding of this project's code.

## General terms and abbreviations

<dl>
  <dt>PGx, PGt</dt>
  <dd>PGx is an abbreviation of <em>pharmacogenomics</em>, the study of how
  pharmacology is affected by <em>the genome as a whole</em>. PGt on the other
  hand is an abbreviation of <em>pharmacogenetics</em>, the study of how
  pharmacology is affected by <em>individual genes</em>. In practice, the two
  terms are often (incorrectly) used as synonyms.</dd>

  <dt>Medication</dt>
  <dd>Linguistically synonymous to the term <em>drug</em>, but preferred for
  this project. Ibuprofen is an example of a <em>medication</em>.</dd>

  <dt>RxNorm, RxCUI</dt>
  <dd><em>RxNorm</em> is a US-specific standardized naming system for
  medications. RxNorm also defines IDs for medications, known as
  <em>RxCUI</em>s.</dd>
  <dd><a href="https://www.merriam-webster.com/dictionary/Rx">Trivia</a>: Rx
  stems from the latin word <em>recipe</em> meaning "take". The first doctor to
  use "Rx" used it as a verb with the same meaning in "Rx two aspirin." on a
  prescription being equivalent to today's "Take two aspirin.". RxCUI stands for
  "Rx concept unique identifier".</dd>

  <dt>Indication</dt>
  <dd>Defines the reason a medication is used, e.g. a headache for
  ibuprofen.</dd>
</dl>

## Biomedical terms

<dl>
  <dt>DNA</dt>
  <dd><em>DNA</em> is the sequence of base pairs that makes up a human's genetic
  code.</dd>

  <dt>Gene</dt>
  <dd>A specific section of the DNA defining how one enzyme is built. The gene
  <em>CYP2D6</em> for example encodes the enzyme <em>CYP2D6</em>. A gene's name,
  for example <em>CYP2D6</em>, is often referred to as a
  <code>GeneSymbol</code>.</dd>

  <dt>Genotype</dt>
  <dd>What exactly a specific gene looks like, i.e. which exact base pairs it's
  made up of, may differ for each individual. This specific sequence of base
  pairs or <em>variant</em> is referred to as the gene's <em>genotype</em>.</dd>

  <dt>Gene result</dt>
  <dd>In practice, the different genotypes can have different effects on the
  encoded enzyme. The <em>gene result</em> describes this effect.  One possible
  gene result for CYP2D6 is "Normal metabolizer".</dd>

  <dt>Phenotype</dt>
  <dd>A gene along with its gene result is referred to as a
  <em>phenotype</em></dd>

  <dt>Allele</dt>
  <dd>In theory, a person has two copies of each gene: one from each parent.
  These copies are called <em>alleles</em>. In reality, the exact number of
  inherited alleles by each parent may be unequal to one. The major way we
  express an allele's genotype is by using the <em>star allele</em> format, e.g.
  <em>CYP2D6*1</em> for CYP2D6's star one variant, which is often used as the
  baseline or "normal" variant of a gene.</dd>

  <dt>Haplotype</dt>
  <dd>Describes the allele(s) inherited by a single parent. If an individual has
  multiple alleles from the same parent, the tar allele format joins them with a
  hyphen, e.g. <em>CYP2D6*1-*2</em> for a haplotype with one CYP2D6 star one and
  one CYP2D6 star two allele.</dd>

  <dt>Diplotype</dt>
  <dd>Describes the allele(s) inherited by both parents, i.e.  the two
  haplotypes. The star allele format defines diplotypes by joining the
  respective haplotypes with a slash, i.e. <em>CYP2D6*1/*2</em> for an
  individual that has one CYP2D6 star one variant from one parent and one star
  two variant from the other.</dd>
</dl>

## Terms used in our projects

<dl>
  <dt>Implication</dt>
  <dd>For a given medication-phenotype pair, an implication describes what
  effects the phenotype has on use of the medication. An example for an
  implication is "Increased risk of side effects".</dd>

  <dt>Recommendation</dt>
  <dd>For a given medication-phenotype pair, a recommendation describes what an
  individual should do based on the corresponding implication, e.g. "Use a lower
  dose".</dd>

  <dt>Guideline</dt>
  <dd>Consists of the implication and recommendation for a given
  medication-phenotype pair.</dd>

  <dt>Annotation</dt>
  <dd>Describes data that is manually curated for our project, i.e. implication
  and recommendation for a medication-phenotype pair and indication and a
  patient-friendly drug-class for a medication.</dd>

  <dt>(Text) Brick</dt>
  <dd>*Text Bricks* are predefined components that are used to create texts for
  annotations. The creation of annotation texts is strictly limited to
  combinations of Bricks to ensure consistency and enable easy multi-language
  support without the need of the maintainer having to know more than one
  supported language. Bricks can also include placeholders such as a given
  medication's name</dd>
</dl>
