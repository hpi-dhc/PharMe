import { IDrug_Any } from '../../database/models/Drug';

type Props = {
    drug: IDrug_Any;
    isEditable: boolean;
};

const BrandNamesAnnotation = ({ drug, isEditable }: Props) => {
    console.log(drug, isEditable);
    return <div></div>;
};

export default BrandNamesAnnotation;
