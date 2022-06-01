import { ApiProperty } from '@nestjs/swagger';

// The Diplotype class is used to define the return type of the
// GET/star-alleles endpoint in the openAPI schema
export class Diplotype {
    @ApiProperty()
    gene: string;
    @ApiProperty()
    resultType: string;
    @ApiProperty()
    genotype: string;
    @ApiProperty()
    phenotype: string;
    @ApiProperty()
    allelesTested: string;
}

// The AllelesFile class is used to define the return type of the
// GET/star-alleles /endpoint in the openAPI schema
export class AllelesFile {
    @ApiProperty()
    organizationId: number;
    @ApiProperty()
    identifier: string;
    @ApiProperty()
    knowledgeBase: string;
    @ApiProperty({ type: Diplotype, isArray: true })
    diplotypes: Diplotype[];
}
