interface Props {
    dark?: boolean;
}

function LoadingSpinner({ dark }: Props) {
    return (
        <div className="flex justify-center items-center">
            <div
                className={`animate-spin inline-block w-8 h-8 opacity-60  border-4 border-t-transparent rounded-full ${
                    dark ? 'border-white' : 'border-black'
                }`}
            />
        </div>
    );
}

export default LoadingSpinner;
