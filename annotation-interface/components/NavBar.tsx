import Link from 'next/link';
import { useRouter } from 'next/router';

interface ITabDefinition {
    activePaths: RegExp;
    title: string;
    linkPath: string;
}

const NavBar = () => {
    const router = useRouter();
    const tabDefinitions: ITabDefinition[] = [
        { activePaths: /^\/$/, title: 'Home', linkPath: '/' },
    ];
    return (
        <div className="h-screen fixed px-8 py-16">
            <ul className="space-y-2">
                {tabDefinitions.map((tabDefinition, index) => (
                    <li
                        key={index}
                        className={`font-medium ${
                            router.pathname.match(tabDefinition.activePaths) &&
                            'underline'
                        }`}
                    >
                        <Link href={tabDefinition.linkPath}>
                            <a>{tabDefinition.title}</a>
                        </Link>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default NavBar;
