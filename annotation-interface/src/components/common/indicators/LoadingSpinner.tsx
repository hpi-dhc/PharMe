function LoadingSpinner() {
    return (
        <div className="flex justify-center items-center">
            <div className="animate-spin inline-block w-8 h-8 border-4 border-black opacity-60 border-t-transparent rounded-full" />
        </div>
    );
}

export default LoadingSpinner;
